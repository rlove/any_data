create or replace type any_data_attribute authid current_user under any_data (
   name varchar2(400),
   data_value any_data,
   overriding member function get_self_family_name return varchar2,
   overriding member function compare_internal( p_other any_data ) return integer,
   overriding member function to_string_array( p_separator varchar2 := null ) return string_array,
   constructor function any_data_attribute( self in out nocopy any_data_attribute, name varchar2, data_value any_data ) return self as result,
   constructor function any_data_attribute(
      self in out nocopy any_data_attribute, type_code number, type_name varchar2, self_type_name varchar2, name varchar2, data_value any_data
   ) return self as result,
   overriding member function get_name_hash return raw,
   overriding member function get_value_hash return raw,
   overriding member function get_type_hash return raw
);
/
