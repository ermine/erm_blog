open Lwt
open Eliom_pervasives
open HTML5.M
open Eliom_parameters

let site_title = "Ermine's Blog"

let srv_home =
  Eliom_services.service
    ~path:[]
    ~get_params:unit
    ()

let default_page content =
  html (head (title (pcdata site_title)) [])
    (body content)

let srv_home_handler () () =
  return (default_page [p [pcdata "Hello, world!"]])

let _ =
  Eliom_output.Html5.register ~service:srv_home srv_home_handler
