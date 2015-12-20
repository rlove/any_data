drop type anydata_helper_timestamp_tz force;
/

create or replace type anydata_helper_timestamp_tz under anydata_helper_timestamp (
   constructor function anydata_helper_timestamp_tz return self as result
);
/

create or replace type body anydata_helper_timestamp_tz as
   constructor function anydata_helper_timestamp_tz return self as result is
      begin
         self.initialize( DBMS_TYPES.TYPECODE_TIMESTAMP_TZ, 'TIMESTAMP WITH TIME ZONE', 'TimestampTZ');
         return;
      end;
   end;
/