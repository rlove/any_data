create or replace type body any_data_interval_ym as

   overriding member function get_self_family_name return varchar2 is
      begin
         return $$PLSQL_UNIT;
      end;

   overriding member function to_string_array( p_separator varchar2 := null ) return string_array is
      begin
         return string_array( 'interval ''' || to_char( data_value ) || ''' year to month' || p_separator );
      end;

   /* Implementation using 'unconstrained' data type workaround
     https://docs.oracle.com/cd/B19306_01/appdev.102/b14261/datatypes.htm
   */
   constructor function any_data_interval_ym( self in out nocopy any_data_interval_ym, p_data yminterval_unconstrained ) return self as result is
      begin
         self.type_code := dbms_types.typecode_interval_ym;
         self.type_name := 'INTERVAL YEAR TO MONTH';
         self.self_type_name := $$PLSQL_UNIT;
         self.data_value := p_data;
         return;
      end;

   overriding member function get_value_hash return raw is
      begin
         return
            case when self.data_value is null then any_data_const.null_hash_value
            else dbms_crypto.hash( utl_raw.cast_to_raw( self.data_value ), dbms_crypto.HASH_MD5 )
            end;
      end;

end;
/
