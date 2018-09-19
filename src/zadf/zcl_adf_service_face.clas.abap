CLASS zcl_adf_service_face DEFINITION
  PUBLIC
  INHERITING FROM zcl_adf_service
  CREATE PUBLIC .

  PUBLIC SECTION.
    METHODS:
      send REDEFINITION.

ENDCLASS.


CLASS zcl_adf_service_face IMPLEMENTATION.

  METHOD send.

    DATA: lo_request TYPE REF TO if_rest_entity.

    DATA(lv_sas_token) = get_sas_token( gv_uri ).

    go_rest_api->set_uri( |/detect?returnFaceId=true&returnFaceLandmarks=false| ).

    add_request_header( iv_name  = |Content-Type|
                        iv_value = |application/json| ).

    add_request_header( iv_name  = |Ocp-Apim-Subscription-Key|
                        iv_value = |f537b67b21484b159bda7e6c77d8f3d1| ).

    add_request_header( iv_name  = |Authorization|
                        iv_value = lv_sas_token ).

    go_rest_api->set_binary_body( request ).

    DATA(lo_response) = go_rest_api->execute(
        method      = 'POST'
        io_entity   = lo_request
        async       = abap_false
        is_retry    = abap_false
    ).

    ev_http_status = go_rest_api->get_status( ).
    go_rest_api->close( ).

    IF lo_response IS BOUND.
      response = go_rest_api->get_http_client( )->response->get_cdata( ).

      lo_response->get_content_type(
        IMPORTING
          ev_media_type = DATA(type)
          et_parameter  = DATA(parameter)    ).

      response = lo_response->get_string_data( ).
      DATA(length) =  lo_response->get_content_length( ).
    ENDIF.

  ENDMETHOD.

ENDCLASS.
