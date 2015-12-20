drop type anydata_helper_interval_ym force;
/

create or replace type anydata_helper_interval_ym under anydata_helper_base (
  constructor function anydata_helper_interval_ym return self as result
);
/

create or replace type body anydata_helper_interval_ym as
   constructor function anydata_helper_interval_ym return self as result is
      begin
         self.initialize( DBMS_TYPES.TYPECODE_INTERVAL_YM, 'INTERVAL YEAR TO MONTH', 'IntervalYM',
                          dyn_sql_helper.to_char( dyn_sql_helper.to_sting_placeholder )
         );
         return;
      end;
   end;
/