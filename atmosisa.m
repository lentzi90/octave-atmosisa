function [T, a, P, rho] = atmosisa(height)
  % ATMOSISA Calculate atmospheric properties at a certain height.
  %
  % CALL SEQUENCE: [T, a, P, rho] = atmosisa(height)
  %
  % INPUT:
  %   height  the altitude in meters
  %
  % OUTPUT:
  %   T     temperature in Kelvin
  %   a     the speed of sound (m/s)
  %   P     pressure (Pa)
  %   rho   density (kg/m^3)
  %
  % MINIMAL WORKING EXAMPLE: Calculate the temperature, speed of sound, pressure
  % and density of the air at the sea level.
  %
  % [T, a, P, rho] = atmosisa(0)
  %
  % WARNING: This function does NOT work exactly as atmosisa in matlab
  % and it may NOT give the same results as that function!
  % I have tried to follow the International Standard Atmosphere model
  % here https://en.wikipedia.org/wiki/International_Standard_Atmosphere
  % The actual resluts may still vary or even be completly wrong.
  
  % PROGRAMMING by Lennart Jern (lennart.jern@gmail.com)
  % 2016-11-16  Initial version
  % 2016-11-19  Corrected formulas, rename and clean up.
  
  % Constants
  g = 9.80665; % Gravity acceleration (m/s^2)
  Rs = 287.058; % Specific gas constant for dry air (J/(kg*K))
  R = 8.31447; % Ideal gas constant (J/(K*mol))
  M = 0.0289644; % Molar mass of dry air (kg/mol)
  
  % Height levels: The atmosphere is divided into 8 different levels
  % with the following boundaries. (units: m, K and Pa)
  heights = [-610, 11000, 20000, 32000, 47000, 51000, 71000, 84852];
  temperatures = [292.15, 216.65, 216.65, 228.65, 270.65, 270.65, 214.65, 186.87];
  pressures = [108900, 22632, 5474.9, 868.02, 110.91, 66.939, 3.9564, 0.3734];
  
  % get a one dimensional copy of height
  altitude = reshape(height, 1, numel(height));
  
  % Initialize levels (used to keep track on what level the altitude belongs to)
  level = ones(1, numel(altitude));
  % Calculate the correct level for each altitude
  % For every altitude
  for i = 1:numel(altitude)
    % For all 'levels'
    for j = 1:1:numel(heights)
      % Find the correct level
      if (altitude(i) < heights(j))
        level(i) = j-1;
        break;
      end
    end
  end
  
  % How far into the level are we?
  delta = altitude - heights(level);
  % Temperature change is assumed to be linear between levels.
  % lapse is the rate of change in temperature (K/m)
  lapse = (temperatures(level+1) - temperatures(level)) ./ (heights(level+1) - heights(level));
  
  % Calculate the temperature
  T = temperatures(level) + delta .* lapse;
  
  % Initialize pressure
  P = ones(size(altitude));
  % We need to use two different formulas:
  % one for levels with zero lapse and another for the rest.
  % Get the indices for altitudes with zero/non-zero lapse
  nz_lapse = lapse ~= 0.0;
  z_lapse = lapse == 0.0;
  % Calculate pressure for non-zero lapse (https://wahiduddin.net/calc/density_altitude.htm)
  P(nz_lapse) = pressures(level(nz_lapse)) .* (1 + lapse(nz_lapse).*delta(nz_lapse) ./ temperatures(level(nz_lapse))).^(-g.*M./(R.*lapse(nz_lapse)));
  % Pressure for levels where lapse is 0 (http://hyperphysics.phy-astr.gsu.edu/hbase/Kinetic/barfor.html)
  P(z_lapse) = pressures(level(z_lapse)).*exp(-g*M.*delta(z_lapse)./(R.*T(z_lapse)));
  
  % Density
  rho = P ./ (Rs.*T);
  % Speed of sound
  a = 331.3 .* sqrt(1 + ((T-273.15) ./ 273.15));
  
  % Reshape the outputs to mirror the input data
  sz = size(height);
  T = reshape(T, sz);
  rho = reshape(rho, sz);
  P = reshape(P, sz);
  a = reshape(a, sz);
end
