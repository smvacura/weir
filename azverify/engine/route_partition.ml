open Parser.Network_types
open Terraform_ir.Route_table

type route_map = (Route.t, (int32 * int32) list) Hashtbl.t


type event_type = 
| Start
| End

type validity = 
| Valid
| Invalid



type event = {
  ip : int32;
  event_type : event_type;
  route : Route.t
}

let get_route_mask route =
  Parser.Network_types.CIDR.get_mask (Route.get_prefix route)

module OrderedEvent = struct
  type t = event

  let compare e1 e2 = 
    match Int32.unsigned_compare e1.ip e2.ip with
    | 0 -> compare (Route.get_source e1.route) (Route.get_source e2.route)
    | i -> i
end
module RouteHeap = Pqueue.MakeMax(Route)


type validity_index = (Route.t, validity) Hashtbl.t

let get_events routes =
  let rec aux routes acc =
    match routes with
    | [] -> acc
    | h::t -> let lo, hi = CIDR.get_interval (Route.get_prefix h) in
              aux t ({ip= lo; event_type=Start; route=h}::{ip=hi; event_type=End; route=h}::acc)
    in
    List.sort OrderedEvent.compare (aux routes [])
    

let init_validity_index events = 
  let validity_index = Hashtbl.create (List.length events / 2) in
  let rec aux events =
    match events with
    | [] -> validity_index
    | h::t -> Hashtbl.replace validity_index h.route Valid; aux t
  in
  aux events


let partition_routes routes : route_map =
  let partitions = Hashtbl.create 10 in
  let events = get_events routes in
  let validity_index = init_validity_index events in
  let route_heap = RouteHeap.create () in
  let current_start : int32 ref = ref 0l in

  let max_is_invalid () = 
    match RouteHeap.max_elt route_heap with
    | Some route -> Hashtbl.find_opt validity_index route = Some Invalid
    | None -> false
  in

  let reshuffle_heap () =
    while max_is_invalid () do
      RouteHeap.remove_max route_heap;
    done
  in

  let route_is_higher_than_max route = 
    match RouteHeap.max_elt route_heap with
    | Some max_route -> Route.compare route max_route > 0 
    | None -> true
  in

  let route_equals_max route = 
    match RouteHeap.max_elt route_heap with
    | Some max_route -> Route.compare route max_route = 0
    | None -> false
  in

  let add_to_partition route lo hi  =
    match Hashtbl.find_opt partitions route with
    | Some l -> Hashtbl.replace partitions route ((lo, hi)::l) 
    | None -> Hashtbl.add partitions route [(lo, hi)]
  in

  let close_interval lo hi =
    if Int32.unsigned_compare lo hi <= 0 then
      match RouteHeap.max_elt route_heap with
      | Some route -> add_to_partition route lo hi
      | None -> ()
  in

  let mark_route_expired route =
    Hashtbl.replace validity_index route Invalid
  in

  let step event  =
    match event.event_type with 
    | Start -> 
        if route_is_higher_than_max event.route 
        then (
          if Int32.unsigned_compare event.ip !current_start > 0 then
            close_interval !current_start (Int32.sub event.ip 1l);
            current_start := event.ip; 
            RouteHeap.add route_heap event.route;
          )
        else RouteHeap.add route_heap event.route; 
    | End -> 
        if route_equals_max event.route 
        then ( 
          if Int32.unsigned_compare event.ip !current_start >= 0 then
            (add_to_partition event.route !current_start event.ip;
            mark_route_expired event.route; 
            reshuffle_heap ());
          current_start := (Int32.add event.ip 1l)
          )
        else (
          mark_route_expired event.route;
        )
  in

  List.iter step events;
  partitions
