# Objective of Paper
- Current explanation methods for GNNs have trouble with counterfactual and model-level explanations.
  - Counterfactual explanations are the opposite of factual explanations; whereas factual explanations ask an explanation for the graph provided, counterfactual explanations ask: "Which changes in the input graph would result in a different outcome?". Counterfactual explanations are useful for explaining how changes in the input effect the output.
  - Model-level explanations built on top of instance-level explanations; whereas instance-level explanations ask for an explanation given an individual, specific graph, model-level explanations are explanations that hold for all possible input graphs in general. Model-level explanations are useful for explaining the general decision-making of a GNN.
- A reason for this is that current GNN explainability methods rely on methods that may produce out-of-distribution input graphs.
  - GNNs are trained on a collection of graphs. These graphs come from a certain distribution, just like all data. Often, graphs from these distributions also follow certain domain-specific rules. For example, graphs of molecules for the designing of drugs must adhere to certain domain-specific rules in order to be considered valid.
  - For GNN explainability, we want to point to specific subgraphs of the input graph. We want to be able to pinpoint the specific neighborhood of nodes that results in specific decision-making of the GNN.
  - Current GNN explainability methods rely on the construction or generation of subgraphs that explain decision-making for a graph. However, these methods may produce subgraphs that do not fall within the distribution of the input graphs. These are out-of-distribution (sub)graphs.
- Graph diffusion models are a recent development capable of generating (sub)graphs from noise that are in-distribution.

# Proposal Made


# Evidence Given

# Shoulders of Giants
## GNN Explainability
- [6] [GNNExplainer: Generating Explanations for Graph Neural Networks](https://arxiv.org/abs/1903.03894) (2019)
  - Early foundational paper on explainability of GNNs.
- [8] [Parameterized Explainer for Graph Neural Network](https://arxiv.org/abs/2011.04573) (2020)
  - A parameterized approach to GNN explainability using deep nets.
- [9] [PGM-Explainer: Probabilistic Graphical Model Explanations for Graph Neural Networks](https://arxiv.org/abs/2010.05788) (2020)
  - A probabilistic graphical model approach to GNN explainability, similar to Bayesian networks.
- [10] [DAG Matters! GFlowNets Enhanced Explainer For Graph Neural Networks](https://arxiv.org/abs/2303.02448) (2022)
  - A generative flow network approach to GNN explainability.
- [11] [Reinforcement Learning Enhanced Explainer for Graph Neural Networks](https://proceedings.neurips.cc/paper/2021/hash/be26abe76fb5c8a4921cf9d3e865b454-Abstract.html) (2021)
  - A reinforcement learning net approach to GNN explainability.

## Graph Diffusion Models
- [19] [DiGress: Discrete Denoising diffusion for graph generation](https://arxiv.org/abs/2209.14734) (2022)
  - A proposed model for the generation of discrete graphs based on the diffusion process.
- [20] [Diffusion Models for Graphs Benefit From Discrete State Spaces](https://arxiv.org/abs/2210.01549) (2022)
  - Discrete graph diffusion using discrete noise samples as opposed to continuous Gaussian samples.

# Impact

# Reproducibility

# Conclusion