clc; clear; close all

R1=readtable("out_Case3D_flap_R1/_mk25.csv");
R2=readtable("out_Case3D_flap_R2/_mk25.csv");
R3=readtable("out_Case3D_flap_R3/_mk25.csv");

hold on
plot(R1.time_s_,R1.pitch_deg_)
plot(R2.time_s_,R2.pitch_deg_)
plot(R3.time_s_,R3.pitch_deg_)

R1=readtable("out_Case3D_wave_R1/_Elevation.csv","NumHeaderLines",3);
R2=readtable("out_Case3D_wave_R2/_Elevation.csv","NumHeaderLines",3);
R3=readtable("out_Case3D_wave_R3/_Elevation.csv","NumHeaderLines",3);

figure(2)
hold on
plot(R1.Time_s_,R1.Elevation_6_m_)
plot(R2.Time_s_,R2.Elevation_6_m_)
plot(R3.Time_s_,R3.Elevation_6_m_)