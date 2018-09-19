*&---------------------------------------------------------------------*
*& Report zadf_demo_azure_face
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zadf_demo_azure_face.

CLASS controller DEFINITION.

  PUBLIC SECTION.
    METHODS: start.

ENDCLASS.

CLASS controller IMPLEMENTATION.

  METHOD start.

    DATA:
      lt_headers TYPE tihttpnvp,
      response   TYPE string,
      status     TYPE i.

    TRY.
        DATA(lo_service) = zcl_adf_service_factory=>create( iv_interface_id = |FACE| ).

        DATA(lo_face) = CAST zcl_adf_service_face( lo_service ).

        lo_face->add_expiry_time( iv_expiry_hour = 0
                                  iv_expiry_min  = 15
                                  iv_expiry_sec  = 0 ).

        DATA(string) = `{"url" : "https://pbs.twimg.com/profile_images/1034718179715690496/m0uHgtbG_400x400.jpg" }`.

        DATA(xstring) = cl_bcs_convert=>string_to_xstring( string ).

        lo_face->send(
          EXPORTING
            request         = xstring
            it_headers      = lt_headers
          IMPORTING
            response        = response
            ev_http_status  = status ).

      CATCH cx_root INTO DATA(lx_error).
        MESSAGE lx_error TYPE 'S' DISPLAY LIKE 'E'.
        RETURN.
    ENDTRY.

    cl_demo_output=>write( response ).
    cl_demo_output=>write( status ).
    cl_demo_output=>display(  ).

  ENDMETHOD.

ENDCLASS.

START-OF-SELECTION.
  NEW controller( )->start( ).
