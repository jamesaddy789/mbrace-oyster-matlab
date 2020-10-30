filename =  'BC_DD_C2_81_05_2A_2018-07-01.bin';
bytes_per_period = 68;
number_of_sensors = 6;

fid = fopen(filename);
d = fread(fid);
fclose(fid);
d = reshape(d, bytes_per_period, []);
d = transpose(d);

millis_bytes = d(:, 3:6);
millis_bytes(1:5, :)
sensor_values = d(:,9:end);
sensor_values = transpose(sensor_values);
sensor_values = sensor_values(:);
row_count = size(sensor_values, 1) / number_of_sensors;
sensor_values = reshape(sensor_values, number_of_sensors, row_count);
sensor_values = transpose(sensor_values);

millis_values = convert_ms_bytes_to_decimal(uint32(millis_bytes));
millis_values(1:5)

%Average data
times_averaged = 10;
number_of_rows = size(sensor_values,1) / times_averaged;
averaged_matrix = zeros(number_of_rows, number_of_sensors);
for i = 1:number_of_sensors
    sensor_column = sensor_values(:,i);
    columns_to_avg = reshape(sensor_column,times_averaged,[]);
    averaged_readings = transpose(mean(columns_to_avg));
    averaged_matrix(:,i) = averaged_readings;
end
sensor_values = averaged_matrix;
normalized_values = sensor_values - min(sensor_values);
plot(normalized_values);

function values = convert_ms_bytes_to_decimal(millis_bytes)
    values = zeros(size(millis_bytes, 1), 1);
    for i = 1:size(values,1)
        %This method uses bitshifting to set the bits of the 32 bit value
        shift_24 = bitshift(millis_bytes(i,1),24);
        shift_16 = bitshift(millis_bytes(i,2),16);
        shift_8 = bitshift(millis_bytes(i,3),8);
        shift_0 = millis_bytes(i,4);
        sum = shift_24 + shift_16 + shift_8 + shift_0;
        values(i,1) = sum;
    end
end





