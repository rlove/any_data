create or replace type any_data_number under any_data(
   data_value number,
   overriding member function to_string_array( p_separator varchar2 := null ) return string_array,
   constructor function any_data_number( self in out nocopy any_data_number, p_data number ) return self as result
);
/

create or replace type body any_data_number as

   overriding member function to_string_array( p_separator varchar2 := null ) return string_array is
      begin
         return string_array( to_char( data_value ) || p_separator );
      end;

   constructor function any_data_number( self in out nocopy any_data_number, p_data number ) return self as result is
      begin
         self.type_info := any_type( dbms_types.typecode_number, 'NUMBER' );
         self.data_value := p_data;
         return;
      end;

end;
/
