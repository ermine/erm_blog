open Lwt
open Eliom_pervasives
open HTML5.M
open Eliom_output.Html5
open Eliom_parameters

let site_title = "Ermine's Blog"

let srv_home =
  Eliom_services.service
    ~path:[]
    ~get_params:unit
    ()

let srv_login_submit =
  Eliom_services.post_coservice'
    ~name:"login"
    ~post_params:(string "username" ** string "password")
    ()

let login_box =
  post_form ~service:srv_login_submit
    (fun (username, password) ->
      [fieldset ~legend:(legend [pcdata "Логин"]) [
        label ~a:[a_for "username"] [pcdata "Имя"];
        string_input ~a:[a_id "username"] ~name:username ~input_type:`Text ();
        br ();
        label ~a:[a_for "password"] [pcdata "Пароль"];
        string_input ~a:[a_id "password"]
          ~name:password ~input_type:`Password ();
        br ();
        string_input ~a:[a_class ["submit"]]
          ~input_type:`Submit ~value:"Войти" ()
      ]])
    
let users : string option Eliom_references.eref = Eliom_references.eref None

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

let srv_login_submit_handler () (username, password) =
  Eliom_references.set users (Some username) >>= fun () ->
  return Eliom_services.void_hidden_coservice'

let _ =
  Eliom_output.Html5.register ~service:srv_home srv_home_handler;
  Eliom_output.Redirection.register ~service:srv_login_submit
    srv_login_submit_handler
