open Lwt
open Eliom_pervasives
open HTML5.M
open Eliom_parameters
open Eliom_output.Html5

let users : string option Eliom_references.eref =
  Eliom_references.eref ~persistent:"erm_users"
    ~scope:`Session ~state_name:"users" None

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
    
let srv_login_submit_handler () (username, password) =
  Eliom_references.set users (Some username) >>= fun () ->
  return Eliom_services.void_hidden_coservice'

let _ =
    Eliom_output.Redirection.register ~service:srv_login_submit
    srv_login_submit_handler
