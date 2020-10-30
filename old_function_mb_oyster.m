function [mb_millis, mb_sensor_values] = get_mb_data(filename, bytes_per_period, number_of_sensors)
    fid = fopen(filename);

    %Store data where columns start at timestamp. inf means all data in the
    %file is retrieved
    d = fread(fid,[bytes_per_period,inf]);

    %close file
    fclose(fid);

    %Swap rows and columns
    d = transpose(d);

    mb_millis = d(1:end,3:6);

    %Cast from matrices of doubles to matrices of bytes
    mb_millis = uint8(mb_millis);

    %Get the sensor values and convert to a 6 column matrix where each
    %column represents a sensor
    v = d(:,9:end);

    % transpose then convert to a single column vector
    v = transpose(v);
    v = v(:);

    row_count = size(v,1) / number_of_sensors;

    v = reshape(v, number_of_sensors, row_count);
    v = transpose(v);

    %mb_sensor_values_with_temp = v;

    %The hall effect sensor values are the first 6 columns
    mb_sensor_values = v(1:end,1:6);

    mb_sensor_values = uint8(mb_sensor_values);
end

%Average data
times_averaged = 10;
averaged_matrix = zeros(size(sensor_readings,1) / times_averaged, size(sensor_readings,2));
for i = 1:size(sensor_readings,2)
    sensor_column = sensor_readings(:,i);
    columns_to_avg = reshape(sensor_column,times_averaged,[]);
    averaged_readings = mean(columns_to_avg)';
    averaged_matrix(:,i) = averaged_readings;
end
sensor_readings = averaged_matrix;

%The millis bytes need to be converted to decimal values for the timestamps
timestamps = convert_ms_bytes_to_decimal(uint32(data_matrix(:,3:6)));

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
