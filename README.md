# MATLAB Traffic Simulation

### Description

This project is the application of my research topic findings for MATH*4600 (_Advanced Research Project in Mathematics_). We aimed to model driver behaviour during sudden braking situations on multi-lane roads.

Given a customizable set of starting parameters, the established model generates incremental data points indicating acceleration, speed, and position at evenly spaced time intervals for a configurable amount of cars. We attempted to create a model which would allow us to personalize driver behaviour reflected by reaction time, aggression, and "impulsiveness" when considering dangerous driving maneuvers (ex. tight lane changes, sudden deceleration, tailgating).

Reaching the end goal would enable researchers to attach driver behaviour to individual vehicles and observe interaction between different classes of drivers, such as "cautious" drivers and "aggressive" drivers, or "drunk" drivers among "inexperienced" drivers.

Alongside developing a model, I also built a [small visualizer](https://github.com/deyvidm/traffic_sim_visualization) to help illustrate the vehicles. It's a small stack of web technologies that accepts a data file generate by the backend. It served as a visual aid for analyzing the resulting behaviour of the modeled vehicles and presenting results to my grading commitee and peers.
