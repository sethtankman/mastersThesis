clear all 
close all
name_datafile9 = 'result.dat';
fid = fopen(name_datafile9);
fn = textscan(fid,'%f %f %f %f %f %f ',...
    5000,'Headerlines',1);
fclose(fid);
safe = fn{1,1};
pump2_action = fn{1,2};
trip_temp= fn{1,3};
trip_time = fn{1,4};
Predicted_PFCL = fn{1,5};
margin=fn{1,6};
[max_margin index]=max(margin);
recommented_PFCL_predicted=Predicted_PFCL(index);
recommended_trip_time=trip_time(index);





