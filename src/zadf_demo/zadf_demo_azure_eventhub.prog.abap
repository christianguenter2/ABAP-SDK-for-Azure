*&---------------------------------------------------------------------*
*& Report  ZADF_DEMO_AZURE_EVENTHUB
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*
REPORT zadf_demo_azure_eventhub.

CLASS controller DEFINITION.

  PUBLIC SECTION.
    METHODS:
      start.

  PRIVATE SECTION.
    TYPES:
      BEGIN OF ty_sflight,
        carrid    TYPE sflight-carrid,
        connid    TYPE sflight-connid,
        fldate    TYPE sflight-fldate,
        planetype TYPE sflight-planetype,
      END OF ty_sflight,
      tty_sflight TYPE STANDARD TABLE OF ty_sflight
                       WITH NON-UNIQUE DEFAULT KEY.

    CONSTANTS:
      gc_interface TYPE zinterface_id VALUE 'HACK-CG'.

    METHODS:
      get_data
        RETURNING
          VALUE(rt_sflight) TYPE controller=>tty_sflight.

ENDCLASS.

CLASS controller IMPLEMENTATION.

  METHOD start.

    DATA:
      lt_headers     TYPE tihttpnvp,
      lv_response    TYPE string,
      lv_filter      TYPE zbusinessid,
      lv_http_status TYPE i,
      lv_xstring     TYPE xstring.

    DATA(lt_sflight) = get_data( ).

    IF lines( lt_sflight ) = 0.
      MESSAGE 'No data in SFLIFHT' TYPE 'E'.
      RETURN.
    ENDIF.

    TRY.
        " Calling Factory method to instantiate eventhub client
        DATA(lo_adf_service) = zcl_adf_service_factory=>create( iv_interface_id        = gc_interface
                                                                iv_business_identifier = lv_filter ).

        DATA(lo_eventhub) = CAST zcl_adf_service_eventhub( lo_adf_service ).

        lo_eventhub->add_expiry_time( iv_expiry_hour = 0
                                      iv_expiry_min  = 15
                                      iv_expiry_sec  = 0 ).

        DATA(lo_json) = NEW cl_trex_json_serializer( lt_sflight ).

        lo_json->serialize( ).
        DATA(lv_string)  = lo_json->get_data( ).

        CALL FUNCTION 'SCMS_STRING_TO_XSTRING'
          EXPORTING
            text   = lv_string
          IMPORTING
            buffer = lv_xstring
          EXCEPTIONS
            failed = 1
            OTHERS = 2.

        lo_eventhub->send(
          EXPORTING
            request        = lv_xstring
            it_headers     = lt_headers
          IMPORTING
            response       = lv_response
            ev_http_status = lv_http_status ).

      CATCH cx_root INTO DATA(lx_error).
        MESSAGE lx_error TYPE 'S' DISPLAY LIKE 'E'.
        RETURN.
    ENDTRY.

    IF lv_http_status NE '201' AND
       lv_http_status NE '200'.
      MESSAGE 'SAP data not sent to Azure EventHub' TYPE 'E'.
    ELSE.
      MESSAGE 'SAP data sent to Azure EventHub' TYPE 'I'.
    ENDIF.

  ENDMETHOD.


  METHOD get_data.

    SELECT carrid, connid, fldate, planetype
           FROM sflight
           INTO TABLE @DATA(lt_sflight).

    CHECK sy-subrc = 0.

    DO 1 TIMES.
      DATA(random_int) = cl_abap_random_int=>create( seed = CONV #( sy-uzeit )
                                                     min  = 1
                                                     max  = lines( lt_sflight ) )->get_next( ).

      DATA(ls_line) = lt_sflight[ random_int ].

      INSERT ls_line INTO TABLE rt_sflight.
    ENDDO.

  ENDMETHOD.

ENDCLASS.

START-OF-SELECTION.
  NEW controller( )->start( ).
