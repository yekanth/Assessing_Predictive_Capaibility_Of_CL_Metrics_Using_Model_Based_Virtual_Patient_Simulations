# Assessing_Predictive_Capaibility_Of_CL_Metrics_Using_Model_Based_Virtual_Patient_Simulations
The repository contains the code to sample the virtual patients from a pre-trained dataset and use them in conjuction with a physics-based mathematical model to predict a given closed-loop controller performance metrics of an unknown dataset

# Brief review of the project
- Physiological closed-loop controller (PCLC) devices, while offering enormous potential benefits — especially in low-resource settings — face significant regulatory challenges. A major challenge is how to rigorously quantify and evaluate a given closed-loop controller's performance across inter-patient variability.

- In this work, we addressed this challenge by developing a mathematical model that accepts hemorrhage and fluid resuscitation rates as inputs and simulates blood pressure dynamics during hemorrhage.

- We used two datasets: one dataset was used to train the model to generate virtual patients by capturing inter-patient variability. The second dataset, involving a known controller managing blood pressure, was used to validate the model. We simulated virtual patients using this known controller and then compared the predicted closed-loop performance metrics from the virtual patients to those observed in the unseen dataset.

- This approach demonstrates the potential for predicting closed-loop controller performance across diverse patient populations, supporting more efficient and robust regulatory evaluation.

# Brief review of the code
- 'MAIN_Submitted_to_UMD_V2_PCLC' is the mathematical model with the controller integrated
- 'MAIN_Submitted_to_UMD_V2_PCLC_Sim_Hem' is the mathematical model with the controller integrated, additionally it has another controller that replicates the actual experimental protocol of hemorrhage by physiologists (in the experiment for a certain time physiologists used MAP > 45mmHg as a condition during hemorrhage to initiate a series of hemorrhages, this is modeled as on-off controller in this model)
- 'Main_Protocol_Simulation.m' is the main function to run the entire code, to process the experimental data, simulate the virtual patients, evaluate closed-loop metrics of vrtual patients and actual experimental data and finally compare them
- 'evaluate_CL_metrics' is used to calculate the closed-loop metrics for a given response
- 'find_fluid_profile' is used to calculate the input fluid from fluid resusictation of a given controller

# Relevant papers and abstract:

Previously, we presented a lumped-parameter model of the cardiovascular system response and performed a quantitative evaluation against in vivo experiments of defined fluid disturbances. These previous results highlighted the predictive capability of the model in response to fluid perturbations compared to experimental data. However, they did not directly address the question of whether simulated testing using the model could predict the performance of PCLC algorithms for automated fluid resuscitation. PCLC systems involve dynamic interactions between control algorithms, physiologic responses, and sensor/actuator behaviors, which present complexities that extend beyond the fluid perturbations modeled in our previous study. Thus, testing the model for PCLC performance characterization is essential to ensure that the automated system can meet the needs for clinical performance by accurately simulating the dynamic interactions between control algorithms and physiological responses. 

Here, we compare the results obtained from in vivo experimental data from anesthetized swine with those from in silico simulation data for an automated fluid resuscitation PCLC algorithm operating in two modes of slow and fast speed. The main aim of this study is to assess if we can predict the PCLC performance metrics of an independent test dataset using the virtual subjects sampled from the training dataset. By reproducing the experiments in an in silico environment with our previously developed computational model, we hypothesized that differences in performance between the two control algorithms observed in the experimental data could be identified from the in silico data to further support the use of computational modeling and simulation in the development of physiologic closed-loop controlled devices. 

Link to Paper 1: https://ieeexplore.ieee.org/abstract/document/10510286 (Development and validation of the mathematical model)
Link to Paper 2: Paper is under review (The above code is related to paper 2)


