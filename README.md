Addison Shuppy

File explanations:
where:
    Model - a trained convolutional neural network.

simpleNetwork.m:
Creates a simple neural network with one hidden layer, three inputs, 
3 hidden nodes, and 1 output node. Weights and biases are set manually.

generateExamples.m: 
Given a model.
Returns training data for that model (trainingData.xls).
This simulates the scenario where we are given a trained Neural Network and
training examples for which the model is correct in 95% of examples.

knowledge_extraction.m:
Given a model.
Extracts logical rules for that model (rawRules1.csv)
Uses an adaptation of the methodology of extraction in Tran, Garcez 2000.

ruleReduce.m:
Given rules from knowlege_extraction.m,
Simplifies the number of rules by removing duplicates and subsuming.  I.e.
c <- a, ~b; c <- a, b; reduces to c <- a.

knowledge_extraction_b.m:
Given a model.
Extracts confidence rules for that model (confidenceRules1.csv)
Extracts rules from a network using the algorithm in Tran, Garcez 2018,
modified to apply to convolutional neural networks instead of Deep Belief
Networks.

logicalNetwork.m:
Incomplete.

confidenceRuleEncoding.m:
Given a model, confidence rules, and training data.
Trains a new Logical Hybrid Neural Network.

logicalRuleConvert.m:
Given logic rules from knowledge_extraction.m or ruleReduce.m,
Revises rules to their true propositional logic form.

truthValueGenerator.m:
Given rules from ruleReduce.m (reducedRules1.xlsx),
calculates the output for all possible input values.

