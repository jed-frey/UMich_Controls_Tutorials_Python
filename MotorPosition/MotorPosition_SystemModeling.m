%% DC Motor Position: System Modeling
%
% Key MATLAB commands used in this tutorial are:
% <http://www.mathworks.com/help/toolbox/control/ref/tf.html |tf|> , 
% <http://www.mathworks.com/help/toolbox/control/ref/ss.html |ss|>
%
%% Physical setup
% A common actuator in control systems is the DC motor. It directly
% provides rotary motion and, coupled with wheels or drums and cables, can
% provide translational motion. The electric equivalent circuit of the
% armature and the free-body diagram of the rotor are shown in the
% following figure. 
% 
% <<Content/MotorPosition/System/Modeling/figures/motor.png>>
%
% For this example, we will assume the following values for the physical
% parameters. These values were derived by experiment from an actual motor
% in Carnegie Mellon's undergraduate controls lab. 
%
%  (J)     moment of inertia of the rotor     3.2284E-6 kg.m^2 
% 
%  (b)     motor viscous friction constant    3.5077E-6 N.m.s 
%
%  (Kb)    electromotive force constant       0.0274 V/rad/sec 
%
%  (Kt)    motor torque constant              0.0274 N.m/Amp 
%
%  (R)     electric resistance                4 Ohm
%
%  (L)     electric inductance                2.75E-6H
%
% In this example, we assume that the input of the system is the voltage
% source (_V_) applied to the motor's armature, while the output is the position of
% the shaft (_theta_). The rotor and shaft are assumed to be rigid. We
% further assume a viscous friction model, that is, the friction torque is
% proportional to shaft angular velocity. 
%
%% System equations
% In general, the torque generated by a DC motor is proportional to the
% armature current and the strength of the magnetic field. In this
% example we will assume that the magnetic field is constant and,
% therefore, that the motor torque is proportional to only the armature current
% _i_ by a constant factor _Kt_ as shown in the equation below. This
% is referred to as an armature-controlled motor.
%
% $$ T = K_t i $$
%
% The back emf, _e_, is proportional to the angular velocity of the shaft by
% a constant factor _Kb_.
%
% $$ e = K_b \dot{\theta} $$
% 
% In SI units, the motor torque and back emf constants are equal, that
% is, _Kt = Ke_; therefore, we will use _K_ to represent both the motor
% torque constant and the back emf constant.
%
% From the figure above, we can derive the following governing equations based on
% Newton's 2nd law and Kirchhoff's voltage law.  
%
% $$  \\ J \ddot{\theta} + b \dot{\theta} = K i $$
%
% $$  L \frac{di}{dt} + Ri = V - K\dot{\theta}$$
%
% *1. Transfer Function*
%
% Applying the Laplace transform, the above modeling equations can be expressed
% in terms of the Laplace variable _s_.
%
% $$  s(Js + b)\Theta(s) =  KI(s) $$
%
% $$ (Ls + R)I(s) = V(s) -  Ks\Theta(s) $$
% 
% We arrive at the following open-loop transfer function by eliminating
% _I_(_s_) between the two above equations, where the rotational speed is
% considered the output and the armature voltage is considered the input.  
%
% $$ P(s) = \frac { \dot{\Theta}(s) }{V(s)} =  \frac{K}{(Js + b)(Ls + R) + K^2} \qquad [\ \frac{rad/sec}{V} \ ] $$
%
% However, during this example we will be looking at the position as the
% output. We can obtain the position by integrating the speed, therefore,
% we just need to divide the above transfer function by _s_.  
%
% $$ \frac {\Theta(s)}{V(s)} =  \frac{K}{s ( (Js + b)(Ls + R) + K^2 )} \qquad  [ \frac{rad}{V} ] $$
%
% *2. State-Space*
%
% The differential equations from above can also be expressed in state-space form by choosing the
% motor position, motor speed and armature current as the state variables. Again the armature voltage 
% is treated as the input and the rotational position is chosen as the output. 
%
% $$ \frac{d}{dt}\left[\begin{array}{c} \theta \\ \ \\ \dot{\theta} \\ \ \\ i \end{array} \right] = 
% \left [\begin{array}{ccc} 0 & 1 & 0 \\ \ \\ 0 & -\frac{b}{J} & \frac{K}{J} \\ \ \\
% 0 & -\frac{K}{L} & -\frac{R}{L} \end{array} \right] \left [\begin{array}{c} \theta \\ \ \\ \dot{\theta} \\ \ \\ i \end{array} \right]  + 
% \left [\begin{array}{c} 0 \\ \ \\ 0 \\ \ \\ \frac{1}{L} \end{array} \right] V$$
%
% $$  y = \left[ \begin{array}{ccc}1 & \ 0 & \ 0 \end{array} \right] \left [\begin{array}{c} \theta \\ \ \\ \dot{\theta} \\ \ \\ i
% \end{array}\right] $$
%
%% Design requirements
% We will want to be able to position the motor very precisely, thus the
% steady-state error of the motor position should be zero when given a
% commanded position. We will also want the steady-state error due to a
% constant disturbance to be zero as well. The other performance
% requirement is that the motor reaches its final position very quickly
% without excessive overshoot. In this case, we want the system to have a settling
% time of 40 ms and an overshoot smaller than 16%.  
%
% If we simulate the reference input by a unit step input, then the
% motor position output should have: 
%
% * Settling time less than 40 milliseconds
% * Overshoot less than 16%
% * No steady-state error, even in the presence of a step disturbance input
%
%% MATLAB representation
% *1. Transfer Function*
%
% We can represent the above open-loop transfer function of the motor in
% MATLAB by defining the parameters and transfer function as follows.
% Running this code in the command window produces the output shown below.

J = 3.2284E-6;
b = 3.5077E-6;
K = 0.0274;
R = 4;
L = 2.75E-6;
s = tf('s');
P_motor = K/(s*((J*s+b)*(L*s+R)+K^2))

%%
% *2. State Space*
%
% We can also represent the system using the state-space equations. The
% following additional MATLAB commands create a state-space model of the
% motor and produce the output shown below when run in the MATLAB command
% window. 

A = [0 1 0
    0 -b/J K/J
    0 -K/L -R/L];
B = [0 ; 0 ; 1/L];
C = [1 0 0];
D = [0];

motor_ss = ss(A,B,C,D)

%%
% The above state-space model can also be generated by converting your
% existing transfer function model into state-space form. This is again
% accomplished with the |ss| command as shown below. 

motor_ss = ss(P_motor);