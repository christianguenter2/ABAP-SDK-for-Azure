*&---------------------------------------------------------------------*
*& Report zadf_demo_azure_computer_vis
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zadf_demo_azure_computer_vis.

PARAMETERS: url TYPE string LOWER CASE OBLIGATORY DEFAULT `http://fachtagfamilie.mh-stiftung.de/wp-content/uploads/sites/3/2017/02/iStock-478224572.jpg`.

CLASS controller DEFINITION.

  PUBLIC SECTION.
    METHODS: start.

ENDCLASS.

CLASS controller IMPLEMENTATION.

  METHOD start.

    TRY.
        DATA(lo_service) = zcl_adf_service_factory=>create( iv_interface_id = |COMP_VIS| ).

        DATA(lo_computer_vision) = CAST zcl_adf_service_computer_vis( lo_service ).

        lo_computer_vision->add_expiry_time( iv_expiry_hour = 0
                                             iv_expiry_min  = 15
                                             iv_expiry_sec  = 0 ).

        DATA(string) = `{"url" : ` && url && ` }`.

        DATA(xstring) = cl_bcs_convert=>string_to_xstring( string ).

        lo_computer_vision->send(
          EXPORTING
            request         = xstring
          IMPORTING
            response        = DATA(response)
            ev_http_status  = DATA(status) ).

        DATA(id) = lo_computer_vision->get_message_id( ).

        SELECT SINGLE FROM zrest_mo_payload
               FIELDS *
               WHERE messageid = @id
               INTO @DATA(ls_payload).

      CATCH cx_root INTO DATA(lx_error).
        MESSAGE lx_error TYPE 'S' DISPLAY LIKE 'E'.
        RETURN.
    ENDTRY.

    cl_demo_output=>write( status ).
    cl_demo_output=>write_json( ls_payload-response ).
    cl_demo_output=>display(  ).

  ENDMETHOD.

ENDCLASS.

START-OF-SELECTION.
  NEW controller( )->start( ).
