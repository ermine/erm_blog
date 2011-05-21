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

let default_page content =
  (Eliom_references.get users >>= function
    | Some user -> return (pcdata user)
    | None -> return (login_box ())
  ) >>= fun login_box ->
  return (html (head (title (pcdata site_title)) [
    HTML5.M.link ~rel:[`Stylesheet]
      ~href:(HTML5.M.uri_of_string"./css/style.css") ()
  ])
            (body [
              div ~a:[a_id "login"] [login_box];
      div ~a:[a_id "content"] content
]))

let srv_home_handler () () =
  default_page [p [pcdata "Hello, world!"]]

let _ =
  Eliom_output.Html5.register ~service:srv_home srv_home_handler
