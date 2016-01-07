drop type anydata_base force;
/

create or replace type anydata_base as object (
   element_name         varchar2(400),
   element_raw_data     anydata,
   element_anytype_info anytype_info,
   anydata_getter       varchar2(400),
   anydata_converter    varchar2(400),
   string_data_getter   varchar2(4000),
member procedure initialize( p_function_suffix varchar2, p_string_data_getter varchar2 ),
member procedure initialize_with_data( p_element_name varchar2, p_element_raw_data anydata ),
member procedure initialize_with_data( p_element_raw_data anydata, p_element_type_info anytype_info ),
member function get_type_name return varchar2,
not final member function get_type_string return varchar2,
member function get_data_getter_sql return varchar2,
member function get_sql_for_piecewise_string return varchar2,
not final member function get_sql_for_value_string return varchar2,
not final member function get_value_as_string return varchar2,
not final member function get_report return varchar2,
member function get_child_type_info( pv_child_position pls_integer ) return anytype_info,
static function construct( p_type_code integer ) return anydata_base,
static function construct( p_field_name varchar2, p_field_value anydata ) return anydata_base
) not final not instantiable;
/

create or replace type body anydata_base as

member procedure initialize( p_function_suffix varchar2, p_string_data_getter varchar2 ) is
      begin
         self.anydata_getter := 'get' || p_function_suffix;
         self.anydata_converter := 'convert' || p_function_suffix;
         self.string_data_getter := p_string_data_getter;
      end;

member procedure initialize_with_data( p_element_name varchar2, p_element_raw_data anydata ) is
      begin
         self.element_name := UPPER( p_element_name );
         self.element_raw_data := p_element_raw_data;
         self.element_anytype_info := anytype_info( p_element_raw_data );
      end;

member procedure initialize_with_data( p_element_raw_data anydata, p_element_type_info anytype_info ) is
      begin
         self.element_raw_data := p_element_raw_data;
         self.element_anytype_info := p_element_type_info;
         self.element_name := self.element_anytype_info.attribute_name;
      end;

member function get_type_name return varchar2 is
      begin
         return
         case
         when element_anytype_info is null
            then 'NULL element_anytype_info'
         else element_anytype_info.get_type( )
         end;
      end;

not final member function get_type_string return varchar2 is
      begin
         return get_type_name( );
      end;

member function get_data_getter_sql return varchar2 is
      begin
         return 'if v_anydata.' || self.anydata_getter || '( v_data ) = DBMS_TYPES.NO_DATA then
                     raise NO_DATA_FOUND;
                  end if;';

      end;

member function get_sql_for_piecewise_string return varchar2 is
      begin
         return '
               declare
                  v_data ' || get_type_string( ) || ';
                  v_attribute_anydata anydata_base := anydata_base.construct(' || anydata_helper.typecode_placeholder || ');
               begin
                  ' || get_data_getter_sql( ) || '
                  v_attribute_anydata.initialize_with_data(
                     anydata.' || anydata_converter || '(v_data),
                     v_anydata_base.get_child_type_info(' || anydata_helper.piecewise_pos_placeholder || ')
                  );
                  v_result := v_result || v_attribute_anydata.get_report();
               end;';
      end;

not final member function get_sql_for_value_string return varchar2 is
      begin
         return '
            declare
               v_anydata_base      anydata_base := :p_in_data;
               v_anydata           anydata := v_anydata_base.element_raw_data;
               v_data ' || get_type_string( ) || ';
            begin
               ' || get_data_getter_sql( ) || '
               :p_result := ' || replace( string_data_getter, anydata_helper.to_sting_placeholder, 'v_data' ) || ';
            end;';
      end;

not final member function get_value_as_string
      return varchar2 is
      v_result varchar2(32767);
      begin
         execute immediate get_sql_for_value_string( ) using self, out v_result;
         return v_result;
      end;

not final member function get_report return varchar2 is
      begin
         return element_name
                || '(' || get_type_name( ) || ')'
                || ' => '
                || get_value_as_string( );
      end;

member function get_child_type_info( pv_child_position pls_integer )
      return anytype_info is
      begin
         return anytype_info( pv_child_position, self.element_anytype_info.attribute_type );
         exception when others then
         raise_Application_error(
            -20000,
            'pv_child_position=' || pv_child_position
            || 'self.element_anytype_info.type_name=' || self.element_anytype_info.type_name
         );
      end;

static function construct( p_type_code integer ) return anydata_base is
      v_result anydata_base;
      begin
         case
            when p_type_code = dbms_types.typecode_date then v_result := anydata_date( );
            when p_type_code = dbms_types.typecode_number then v_result := anydata_number( );
            when p_type_code = dbms_types.typecode_raw then v_result := anydata_raw( );
            when p_type_code = dbms_types.typecode_char then v_result := anydata_char( );
            when p_type_code = dbms_types.typecode_varchar2 then v_result := anydata_varchar2( );
            when p_type_code = dbms_types.typecode_varchar then v_result := anydata_varchar( );
            when p_type_code = dbms_types.typecode_blob then v_result := anydata_blob( );
            when p_type_code = dbms_types.typecode_bfile then v_result := anydata_bfile( );
            when p_type_code = dbms_types.typecode_clob then v_result := anydata_clob( );
            when p_type_code = dbms_types.typecode_cfile then v_result := anydata_cfile( );
            when p_type_code = dbms_types.typecode_timestamp then v_result := anydata_timestamp( );
            when p_type_code = dbms_types.typecode_timestamp_tz then v_result := anydata_timestamp_tz( );
            when p_type_code = dbms_types.typecode_timestamp_ltz then v_result := anydata_timestamp_ltz( );
            when p_type_code = dbms_types.typecode_interval_ym then v_result := anydata_interval_ym( );
            when p_type_code = dbms_types.typecode_interval_ds then v_result := anydata_interval_ds( );
            when p_type_code = dbms_types.typecode_nchar then v_result := anydata_nchar( );
            when p_type_code = dbms_types.typecode_nvarchar2 then v_result := anydata_nvarchar2( );
            when p_type_code = dbms_types.typecode_nclob then v_result := anydata_nclob( );
            when p_type_code = dbms_types.typecode_bfloat then v_result := anydata_bfloat( );
            when p_type_code = dbms_types.typecode_bdouble then v_result := anydata_bdouble( );
            when p_type_code = dbms_types.typecode_object then v_result := anydata_object( );
            when p_type_code = dbms_types.typecode_varray then v_result := anydata_collection( );
            when p_type_code = dbms_types.typecode_table then v_result := anydata_collection( );
            when p_type_code = dbms_types.typecode_namedcollection then v_result := anydata_collection( );
         end case;
         v_result.element_anytype_info := anytype_info( p_type_code );
         return v_result;
      end;

static function construct( p_field_name varchar2, p_field_value anydata ) return anydata_base is
      v_type    anytype;
      v_anydata anydata_base;
      begin
         v_anydata := anydata_base.construct( p_field_value.gettype( v_type ) );
         v_anydata.initialize_with_data( p_field_name, p_field_value );
         return v_anydata;
      end;
end;
/
