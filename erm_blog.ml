open Lwt
open Eliom_pervasives
open HTML5.M
open Eliom_output.Html5
open Eliom_parameters

open Erm_login

let site_title = "Ermine's Blog"

let srv_home =
  Eliom_services.service
    ~path:[]
    ~get_params:unit
    ()

let visited_eref = Eliom_references.eref 0

let visited_page =
  let mutex = Lwt_mutex.create () in
    fun () ->
      Lwt_mutex.lock mutex >>= fun () ->
      Eliom_references.get visited_eref >>= fun i ->
      let j = succ i in
        Eliom_references.set visited_eref j >>= fun () ->
      Lwt_mutex.unlock mutex;
        return j

let default_page content =
  (Eliom_references.get users >>= function
    | Some user -> return [pcdata user;
                           logout_box ()]
    | None -> return [login_box ()]
  ) >>= fun login_box ->
  visited_page () >>= fun v ->
  return (html
            (head (title (pcdata site_title)) [
              HTML5.M.link ~rel:[`Stylesheet]
                ~href:(HTML5.M.uri_of_string"./css/style.css") ()
            ])
            (body [
              div ~a:[a_id "login"] login_box;
              div ~a:[a_id "content"] content;
              div ~a:[a_id "footer"] [p [pcdata "(c) 2011 ermine"];
                                      p [pcdata ("Просмотров: " ^ string_of_int v)]
                                     ]
            ]))

let srv_home_handler () () =
  default_page [p [pcdata "Hello, world!"]]

let _ =
  Eliom_output.Html5.register ~service:srv_home srv_home_handler
