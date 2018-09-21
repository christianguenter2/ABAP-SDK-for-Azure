CLASS zcl_adf_service_computer_vis DEFINITION
  PUBLIC
  INHERITING FROM zcl_adf_service
  CREATE PUBLIC .

  PUBLIC SECTION.

    METHODS:
      send REDEFINITION.

ENDCLASS.



CLASS zcl_adf_service_computer_vis IMPLEMENTATION.

  METHOD send.

    go_rest_api->set_uri( |/analyze?visualFeatures=Categories&language=en | ).

    add_request_header( iv_name  = |Ocp-Apim-Subscription-Key|
                        iv_value = |2f9fd407954443ceaa901bfc6cd9bb98| ).
    super->send(
      EXPORTING
        request         = request
        it_headers      = it_headers
      IMPORTING
        response        = response
        ev_http_status  = ev_http_status ).

  ENDMETHOD.

ENDCLASS.
