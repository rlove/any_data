create or replace package body anydata_reporter is

   --declaration

   --definition

   /*   function report_collection_type( p_field BETTER_ANYDATA, p_type_info ANYTYPE_INFO, p_indent integer )
         return varchar2 is
         v_indent_str      varchar2(1000) := LPAD( ' ', p_indent, ' ' );
         v_child_type_info ANYTYPE_INFO;
         v_sql             varchar2(32767);
         v_report          varchar2(32767);
         begin
            v_child_type_info := p_type_info.get_child_type_info( 1 );
            v_sql := '
           DECLARE
             v_collection       ANYDATA   := :p_data;
             v_coll_element     ' || v_child_type_info.get_typename( ) || ';
             v_child_type_info  ANYTYPE_INFO := :v_child_type_info;
             v_report           VARCHAR2(32767);
           BEGIN
             v_collection.piecewise();
             WHILE v_collection.' || v_child_type_info.anydata_getter || '( v_coll_element ) != DBMS_TYPES.NO_DATA LOOP
               v_report := v_report || anydata_reporter.NEW_LINE
                 || anydata_reporter.get_report( '''', ANYDATA.' || v_child_type_info.anydata_converter || '( v_coll_element ), :p_indent + anydata_reporter.INDENT_AMOUNT )
                 || '','';
             END LOOP;
             :p_report := v_report;
           END;';
            DBMS_OUTPUT.PUT_LINE( v_sql );
            execute immediate v_sql using p_field.base_data, v_child_type_info, p_indent, out v_report;

            return '[' || RTRIM( v_report, ',' ) || NEW_LINE || v_indent_str || ']';
         end;

      function report_complex_type( p_field BETTER_ANYDATA, p_type_info ANYTYPE_INFO, p_indent integer )
         return varchar2 is
         v_attibute_type_info ANYTYPE_INFO;
         v_field              BETTER_ANYDATA := p_field;
         v_report             varchar2(32767);
         v_result             varchar2(32767);
         v_elem_idx           integer := 1;
         begin
            v_field.base_data.piecewise( );
            loop
               exit when v_elem_idx > COALESCE( p_type_info.COUNT, v_elem_idx );
               begin
                  v_attibute_type_info := ANYTYPE_INFO( v_elem_idx, p_type_info.attribute_type );
                  v_report := get_report( v_field, v_attibute_type_info, p_indent );
                  v_result := v_result || NEW_LINE || v_report || ',';
                  exception
                  when NO_DATA_FOUND then
                  exit;
               end;
               v_elem_idx := v_elem_idx + 1;
            end loop;
            v_result := RTRIM( v_result, ',' ) || NEW_LINE;
            return v_result;
         end;

      function report_object_type( p_field BETTER_ANYDATA, p_type_info ANYTYPE_INFO, p_indent integer )
         return varchar2 is
         v_indent_str  varchar2(1000) := LPAD( ' ', p_indent, ' ' );
         v_out_anydata ANYDATA;
         v_report      varchar2(32767);
         v_sql         varchar2(32767);
         begin
            v_sql := '
           DECLARE
             v_in_data ANYDATA := :base_data_in;
             v_obj     ' || p_type_info.get_typename( ) || ';
             v_element  BETTER_ANYDATA;
           BEGIN
             IF v_in_data.getTypeName() != ''' || p_type_info.get_typename( ) || ''' THEN
               v_in_data.piecewise();
             END IF;
             IF v_in_data.getObject( v_obj ) = DBMS_TYPES.NO_DATA THEN
               RAISE NO_DATA_FOUND;
             END IF;
             v_element := BETTER_ANYDATA( ANYDATA.convertObject( v_obj ) );
             :v_report := anydata_reporter.report_complex_type( v_element, :p_type_info, :p_indent + anydata_reporter.INDENT_AMOUNT );
           END;';
            execute immediate v_sql using in p_field.base_data, out v_report, in p_type_info, in p_indent;
            return '{' || v_report || v_indent_str || '}';
         end;

      function get_report( p_field anydata_element, p_indent integer )
         return varchar2 is
         v_indent_str varchar2(1000) := lpad( ' ', p_indent, ' ' );
         begin
            return v_indent_str || p_field.element_anytype_info.get_report( )
                   || case
                      when p_type_info.type_code = DBMS_TYPES.TYPECODE_OBJECT
                         then report_object_type( p_field, p_type_info, p_indent )
                      when p_type_info.type_code in
                           ( DBMS_TYPES.TYPECODE_VARRAY, DBMS_TYPES.TYPECODE_TABLE, DBMS_TYPES.TYPECODE_NAMEDCOLLECTION )
                         then
                            report_collection_type( p_field, p_type_info, p_indent )
                      end;
         end;*/

   function get_report( p_field_name varchar2, p_field_value anydata, p_indent integer := 0 )
      return varchar2 is
      v_anydata_helper anydata_helper_base;
      begin
         v_anydata_helper := get_anydata_helper( p_field_name, p_field_value );
         return v_anydata_helper.get_report( );
      end;

   function get_anydata_helper( p_field_name varchar2, p_field_value anydata )
      return anydata_helper_base is
      v_type_code      int;
      v_type           anytype;
      v_anydata_helper anydata_helper_base;
      begin
         v_type_code := p_field_value.gettype( v_type );

         case v_type_code
         when dbms_types.typecode_date
            then v_anydata_helper := anydata_helper_date( );
         when dbms_types.typecode_number
            then v_anydata_helper := anydata_helper_number( );
         when dbms_types.typecode_raw
            then v_anydata_helper := anydata_helper_raw( );
         when dbms_types.typecode_char
            then v_anydata_helper := anydata_helper_char( );
         when dbms_types.typecode_varchar2
            then v_anydata_helper := anydata_helper_varchar2( );
         when dbms_types.typecode_varchar
            then v_anydata_helper := anydata_helper_varchar( );
         when dbms_types.typecode_blob
            then v_anydata_helper := anydata_helper_blob( );
         when dbms_types.typecode_bfile
            then v_anydata_helper := anydata_helper_bfile( );
         when dbms_types.typecode_clob
            then v_anydata_helper := anydata_helper_clob( );
         when dbms_types.typecode_cfile
            then v_anydata_helper := anydata_helper_cfile( );
         when dbms_types.typecode_timestamp
            then v_anydata_helper := anydata_helper_timestamp( );
         when dbms_types.typecode_timestamp_tz
            then v_anydata_helper := anydata_helper_timestamp_tz( );
         when dbms_types.typecode_timestamp_ltz
            then v_anydata_helper := anydata_helper_timestamp_ltz( );
         when dbms_types.typecode_interval_ym
            then v_anydata_helper := anydata_helper_interval_ym( );
         when dbms_types.typecode_interval_ds
            then v_anydata_helper := anydata_helper_interval_ds( );
         when dbms_types.typecode_nchar
            then v_anydata_helper := anydata_helper_nchar( );
         when dbms_types.typecode_nvarchar2
            then v_anydata_helper := anydata_helper_nvarchar2( );
         when dbms_types.typecode_nclob
            then v_anydata_helper := anydata_helper_nclob( );
         when dbms_types.typecode_bfloat
            then v_anydata_helper := anydata_helper_bfloat( );
         when dbms_types.typecode_bdouble
            then v_anydata_helper := anydata_helper_bdouble( );
         when dbms_types.typecode_object
            then v_anydata_helper := anydata_helper_object( );
         when dbms_types.typecode_varray
            then v_anydata_helper := anydata_helper_collection( );
         when dbms_types.typecode_table
            then v_anydata_helper := anydata_helper_collection( );
         when dbms_types.typecode_namedcollection
            then v_anydata_helper := anydata_helper_collection( );
         end case;
         v_anydata_helper.initialize_with_data( p_field_name, p_field_value );
         return v_anydata_helper;
      end;
end;
/