create or replace type body any_data_attribute is

   overriding member function get_self_family_name return varchar2 is
      begin
         return 'any_data_attribute';
      end;

   overriding member function compare_internal( p_other any_data ) return integer is
      begin
         return
            case
               when any_data_const.nulls_are_equal
                and self.data_value is null and treat(p_other as any_data_attribute).data_value is null then 0
               when self.data_value is null
               then null
               when self.name = treat(p_other as any_data_attribute).name
               then self.data_value.compare( treat(p_other as any_data_attribute).data_value )
               when self.name > treat(p_other as any_data_attribute).name
               then 1
               when self.name < treat(p_other as any_data_attribute).name
               then -1
            end;
      end;

   overriding member function to_string_array( p_separator varchar2 := null ) return string_array is
      v_result string_array;
      begin
         v_result := data_value.to_string_array( p_separator );
         v_result(1) := name || ' => ' || v_result(1);
         return v_result;
      end;

   constructor function any_data_attribute( self in out nocopy any_data_attribute, name varchar2, data_value any_data ) return self as result is
      begin
         self.self_type_name := 'any_data_attribute';
         self.name := lower(name);
         self.data_value := data_value;
         return;
      end;
   constructor function any_data_attribute(
      self in out nocopy any_data_attribute, type_code number, type_name varchar2, self_type_name varchar2, name varchar2, data_value any_data
   ) return self as result is
      begin
         self.self_type_name := 'any_data_attribute';
         self.name := lower(name);
         self.data_value := data_value;
         return;
      end;


end;
/