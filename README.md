Addison Shuppy

File explanations:
where:
    Model - a trained convolutional neural network.

generateExamples.m: 
Given a model.
Returns training data for that model (trainingData.xls).
This simulates the scenario where we are given a trained Neural Network and
training examples for which the model is correct in 95% of examples.

knowledge_extraction_b.m:
Given a model.
Extracts confidence rules for that model (confidenceRules1.csv)

Extracts rules from a network using the algorithm in Tran, Garcez 2018,
modified to apply to convolutional neural networks instead of Deep Belief
Networks.

confidenceRuleEncoding.m:
Given a model, confidence rules, and training data.
Trains a new Logical Hybrid Neural Network.

