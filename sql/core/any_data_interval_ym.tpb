create or replace type body any_data_interval_ym as

   overriding member function get_self_family_name return varchar2 is
      begin
         return 'any_data_interval_ym';
      end;

   overriding member function to_string_array( p_separator varchar2 := null ) return string_array is
      begin
         return string_array( 'interval ''' || to_char( data_value ) || ''' year to month' || p_separator );
      end;

   /* Alternative implementation using 'unconstrained' data type workaround
     https://docs.oracle.com/cd/B19306_01/appdev.102/b14261/datatypes.htm
   */
   constructor function any_data_interval_ym( self in out nocopy any_data_interval_ym, p_data yminterval_unconstrained ) return self as result is
      begin
         self.type_code := dbms_types.typecode_interval_ym;
         self.type_name := 'INTERVAL YEAR TO MONTH';
         self.self_type_name := 'any_data_interval_ym';
         self.data_value := p_data;
         return;
      end;

end;
/