create or replace type any_data_varchar authid current_user under any_data(
   data_value varchar(32767),
   overriding member function to_string_array( p_separator varchar2 := null ) return string_array,
   constructor function any_data_varchar( self in out nocopy any_data_varchar, p_data varchar ) return self as result
);
/

create or replace type body any_data_varchar as

   overriding member function to_string_array( p_separator varchar2 := null ) return string_array is
      begin
         return string_array( ''''||replace( data_value, '''', '''''')||'''' || p_separator );
      end;

   constructor function any_data_varchar( self in out nocopy any_data_varchar, p_data varchar ) return self as result is
      begin
         self.type_code := dbms_types.typecode_varchar;
         self.type_name := 'VARCHAR';
         self.data_value := p_data;
         return;
      end;

end;
/
