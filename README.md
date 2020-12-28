## Formal Model of Proactivity - Dual Control Mechanism
Our goal is to propose and evaluate a formal model of meta-control decisions in AX-CPT task based on the Dual Control Mechanism.

## What this repository contain
In this repository, you will find the code used to fit the data and generate predictions for AX-CPT tasks based on different models. 
A detailed example with how to fit the data and how the predictions were generate for Mäki-Marttunen et al. (2019) can be found in the matlab live script *"Maki_DMC_model.mlx"*.
the function **fitMetaControlModel** (*functions/fitMetaControlModel.m*) can be used to fit different models. It can also be easily adapted to fit new models. Each model has its own No-Go variant. 

The functions **MeasureGoalDirectedness** (*functions/MeasureGoalDirectedness.m*) and **MeasureReactivity** (*functions/Reactivity.m*) measure the distance between the observed accuracies and the predicted accuracies with a complete goal-directed or reactive strategy, respectively.

## Data Availability 
In this project, we used published data from Mäki-Marttunen (2019), Gonthier (2016) and Redick (2014). The data is available with their respective authors.

### References 
* Gonthier, C., Macnamara, B. N., Chow, M., Conway, A. R., & Braver, T. S. (2016). Inducing proactive control shifts in the AX-CPT. Frontiers in Psychology, 7, 1822.
* Mäki-Marttunen, V., Hagen, T., & Espeseth, T. (2019). Proactive and reactive modes of cognitive control can operate independently and simultaneously. Acta Psychologica, 199, 102891.
* Redick, T. S. (2014). Cognitive control in context: Working memory capacity and proactive control. Acta Psychologica, 145, 1-9.
