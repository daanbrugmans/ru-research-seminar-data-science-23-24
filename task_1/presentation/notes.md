# Objective of Paper
- Current explanation methods for GNNs have trouble with counterfactual and model-level explanations.
  - Counterfactual explanations are the opposite of factual explanations; whereas factual explanations result in an explanation for the specific graph that is provided, counterfactual explanations ask: "Which changes in the input graph would result in a different outcome?". Counterfactual explanations are useful for explaining how changes in the input effect the output.
  - Model-level explanations build on top of instance-level explanations; whereas instance-level explanations result in an explanation for an individual, specific graph, model-level explanations are explanations that hold for all possible input graphs in general. Model-level explanations are useful for explaining the general decision-making of a GNN.
  - Formally, let $f$ be the GNN that should be explained, and let $G$ be the graph that is the input to $f$. Then $f(G)$ gives the label predicted by the GNN for the graph, denoted as $\hat{Y}_G$. 
    - A counterfactual explanation $G^c$ of $f$ can then be defined as a problem of finding the minimal difference between $G$ and $G^c$ that results in $\hat{Y}_G \neq \hat{Y}_{G^c}$.
    - A model-level explanation $G^m$ of $f$ can then be defined as a problem of finding the arguments of the maximum for the likelihood of a certain label being predicted by the GNN given the graph: $\arg\max_G P_f(Y|G)$.
- A reason for this is that current GNN explainability methods rely on methods that may produce out-of-distribution input graphs.
  - GNNs are trained on a collection of graphs. These graphs come from a certain distribution, just like all data. Often, graphs from these distributions also follow certain domain-specific rules. For example, graphs of molecules for the designing of drugs must adhere to certain domain-specific rules in order to be considered valid.
  - For GNN explainability, we want to point to specific subgraphs of the input graph. We want to be able to pinpoint the specific neighborhood of nodes that results in specific decision-making of the GNN.
  - Current GNN explainability methods rely on the construction or generation of subgraphs that explain decision-making for a graph. However, these methods may produce subgraphs that do not fall within the distribution of the input graphs. These are out-of-distribution (sub)graphs.
- Graph diffusion models are a recent development capable of generating (sub)graphs from noise that are in-distribution.
  - In diffusion, noise is introduced step-wise to the input until the input is all noise. Then, a model attempts to learn to remove the noise introduced in every step by going through the steps backwards, removing noise as it goes. After training, a diffusion model can be supplied a collection of noise and "denoise" it, even if the noise is purely random and does not exist on top of an input. This means that diffusion models can generate data based on noise. A well-known example is the generation of images from noise.
  - The diffusion process can also be applied to graphs: noise is introduced step-wise to a graph, then a model learns to remove the noise at every step. After training, the model is able to generate graphs from noise.
  - Since the diffusion model is trained unsupervised on a dataset, learning to approximate the distribution of the data it trained on, diffusion models are capable of generating in-distribution data for many kinds of data, including images and graphs.
  - Formally, let $t \in [0, T]$ be the current timestep, and thus noise level, of the forward diffusion, $A_t$ the (one-hot encoded) adjacency matrix of the graph at timestep $t$, $a_t^{ij} \in A_t$ the (one-hot encoded) existence of an edge between nodes $i$ and $j$ at timestep $t$, $Q_t \in \mathbb{R}^{2 \times 2}$ the stochastic matrix that defines how noise is introduced at timestep $t$ (since the forward diffusion process is a Markov chain), and $Cat(x; P)$ the categorical distribution over the (one-hot encoded) vector $x$ and probability vector $P$.
    - Then the forward diffusion process of a node $a_t^{ij}$ can be written as a function of the presence of an edge at the current timestep given the presence of the edge at the prior timestep: $q(a_t^{ij} | a_{t-1}^{ij}) = Cat(x = a_t^{ij}; P = a_{t-1}^{ij}Q_t)$.
    - Since the forward diffusion process of the graph $G$ is identical to the forward diffusion process over all edges in $A_t$, it can be described as a function of the graph at the current timestep given the graph at the prior timestep: $q(G_t|G_{t-1}) = \prod_{ij} q(a_t^{ij}|a_{t-1}^{ij})$.

# Proposal Made
- The proposal made by the authors is D4Explainer.
  - D4Explainer is a graph diffusion model. D4Explainer is trained using the diffusion process. In the forward diffusion process, noise is added step-wise to an in-distribution graph. This noise consists of the addition and/or removal of edges. In the backwards denoising process, the model learns to step-wise remove this noise. 
  - By including both generative graph distribution learning and the preservation of the counterfactual property into the model's loss function, the model can be learned to generate in-distribution subgraphs that serve as counterfactual explanations.
  - When trained on eight different datasets, D4Explainer has shown state-of-the-art performance for counterfactual and model-level explanations of GNNs. It achieves a counterfactual accuracy of over 80% when only 5% of the edges are modified. Compared with baselines of GNN explanation models, D4Explainer's explanations come closest to the datasets' original distributions.
  - D4Explainer is only capable of discrete structural diffusion. Diffusion over continuous features is explicitly not considered.
- The proposal offers three contributions:
  1. Using the diffusion process, a model is taught to generate in-distribution graphs from noise. These graphs are then in-distribution, diverse, and robust explanations of a GNN's decision-making.
  2. By allowing the addition of edges in a graph during the diffusion process, the diffusion model can be taught to give counterfactual explanations, since it learns how small changes in graph structure changes predictions. This provides a high-level understanding of the effect of edge addition in counterfactual explanations.
  3. The diffusion model is the first graph diffusion model capable of both counterfactual and model-level explanations that are faithful.
- D4Explainer is capable of counterfactual explanations of GNNs.
![A visualization of the counterfactual explanation process of D4Explainer](./images/d4explainer_counterfactual_explanations.png "D4Explainer Counterfactual Explanation")
  - The counterfactual explanation of a GNN starts with a forward diffusion process. The graph $G$ that is the input of the GNN that should be counterfactually explained is taken to be the first step of the forwards diffusion process $G_0$. At every timestep $t \in [0, T]$, noise is added to the graph. This noise is random removal and/or addition of edges. This means that every $G_{t+1}$ is $G_t$ with new edges added and/or removed. At the end of the forwards diffusion process, we get the fully noisy graph $G_T$.
  - After the generation of $G_T$, the backwards diffusion model $p_\theta(G_0|G_t)$ attempts to remove all noise from any noisy $G_t$ by predicting $G_0$. This denoising model uses the adjacency matrix $A_t$ of the noisy graph $G_t$, the node features $X_0$ of the original graph $G_0$, and the current timestep $t$ to construct a dense adjacency matrix, which is a matrix $A$ of probabilities where $a^{ij} \in A$ is the likelihood that there exists an edge between $i$ and $j$. A sparse adjacency matrix $A_0$ may then be sampled from the dense adjacency matrix in order to make a reconstruction of the original graph, $\tilde{G}_0$. Additionally, the current timestep $t$ is also served as the only input to an MLP that produces one output containing time-related latent information embedded in $t$. This MLP has one hidden layer of four units and its output is used as an input for the denoising model. 
  - In order to train the denoising model $p_\theta(G_0|G_t)$, a custom loss function has been designed. This loss function $\mathcal{L}(\theta)$ consists of two seperate loss functions, $\mathcal{L}_{dist}$ and $\mathcal{L}_{cf}$. 
    - $\mathcal{L}_{dist}$ is a loss function used for optimizing to the in-distribution property: minimizing this loss improves the reconstructed graph's $\tilde{G_0}$ similarity to the original graph $G_0$. $\mathcal{L}_{dist}$ includes expected values for the training data's distribution and the forwards diffusion model's distribution in addition to the log of the denoising model's distribution $p_\theta(G_0 | G_t)$. In practice, $\mathcal{L}_{dist}$ is equal to the cross-entropy loss between $G_0$ and $p_\theta(G_0 | G_t)$, comparing the differences between the original and the reconstructed graphs.
    - $\mathcal{L}_{cf}$ is a loss function used for optimizing for the counterfactual property: minimizing this loss improves the likelihood that the generated graph $\tilde{G_0}$ produces a different label than the original graph $G_0$. $\mathcal{L}_{cf}$ uses the expected values of the training data distribution, the current timestep $t$, the forward diffusion model's distribution, and the denoising model's distribution, in addition to the log of the likelihood that the GNN $f$ predicts the label of the original graph $G_0$ when the input is the reconstructed graph $\tilde{G_0}$, subtracted from 1.
  - The final loss function is a weighted sum of the distributional loss and the counterfactual loss: $\mathcal{L}(\theta) = \mathcal{L}_{dist} + \alpha \mathcal{L}_{cf}$. Here, $\alpha$ is a hyperparameter that sets the importance of the counterfactual loss over the distributional loss. This is relevant since the importance of one loss over the other is a trade-off: if the distributional loss outweighs the counterfactual loss too much, the reconstructed graph $\tilde{G_0}$ may be close to the original graph $G_0$ without producing a different label, while if the opposite is true, the denoising model may generate a reconstructed graph $\tilde{G_0}$ that gives a different label, but is so different from the original graph $G_0$ that it is not a useful explanation. When $\alpha$ balances the two losses well enough, $\mathcal{L}(\theta)$ promotes the removal of edges in the recreated graph $\tilde{G_0}$ that are redundant for the counterfactual explanation, while reconstructing edges present in the original graph $G_0$ so that the reconstructed graph remains in-distribution.
  - This architecture for the generation of counterfactual explanations gives D4Explainer multiple merits. Aside from adhering to the in-distribution property, D4Explainer can also be said to be diverse and robust in its explanations. 
    - Diversity means that D4Explainer is capable of giving a diverse set of counterfactual explanations. Due to the diffusion architecture, different reconstructed graphs can give counterfactual explanations for the same input graph. 
    - Robustness means that D4Explainer is capable of giving explanations that are consistently useful, even when graphs are noisy. Due to the diffusion architecture, D4Explainer can consistently generate counterfactual explanations that are devoid of noise or vagueness.
- D4Explainer is capable of model-level explanations of GNNs.
![A visualization of the model-level explanation process of D4Explainer](./images/d4explainer_model_level_explanations.png "D4Explainer Model-level Explanation")
  - D4Explainer's model-level explanations are based on the assumption that the graph that is most likely to belong to a certain class, is also a good general representation of all graphs belonging to that class. If the GNN $f$ whose behavior should be explained for graphs of class $C$ predicts that a graph $G$ is very highly likely to belong to class $C$, then it is assumed that the GNN has found certain subgraphs, feature values, and/or other characteristics in $G$ that are generally very relevant and typical of graphs belonging to class $C$. D4Explainer performs model-level explanations based on this assumption: by attempting to reconstruct a graph $\tilde{G}$ that is predicted by the GNN to be very highly likely to belong to class $C$, a graph is found that, according to the GNN's decision-making, is a very typical example of a graph belonging to class $C$. This graph would then serve as a model-level explanation for the GNN's decision-making process for class $C$.
  - D4Explainer's model-level explanations are generated using a reverse sampling process. This process begins with the generation of a random, fully noisy graph $G_T$. An algorithm is then iteratively performed for all timesteps $t \in (0, T]$:
    1. Use the denoising model $p_\theta$ to calculate the dense adjacency matrix of the original input graph $G_0$ given the noisy graph: $p_\theta(G_0|G_t)$. From the dense adjacency matrix, a discrete adjacency matrix $A_t$ is sampled $K$ times, resulting in $K$ reconstructions of the original graph $\tilde{G}_0$. This set of reconstructions are the candidate explanations of the current timestep.
    2. Use the GNN $f$ to calculate the likelihood of any candidate explanation $\tilde{G}_0$ belonging to class $C$, for all candidates in the set: $P(\hat{Y}_{\tilde{G}_0} = C) = f(\tilde{G}_0)$.
    3. The candidate $\tilde{G}_0$ with the highest likelihood of belonging to class $C$ is taken to be the temporary best explanation of the GNN for class $C$.
    4. Use the forwards diffusion process $q$ to generate a noisy graph with a timestep (noise level) that is one level lower than the current timestep with the temporary best explanation $\tilde{G}_0$ as the base: $G_{t-1} \sim q(G_{t-1}|\tilde{G}_0)$.
    5. Use $G_{t-1}$ as the noisy graph to sample candidate explanations from in the first step of the algorithm during the next iteration $t-1$.
  - After the final iteration $t = 1$ has finished, we take the temporary best explanation $\tilde{G}_0$ to be the final model-level explanation of $f$ for class $C$.
  - The loss function of D4Explainer's model-level explanation model is the distribution loss $\mathcal{L}_{dist}$. The counterfactual loss $\mathcal{L}_{cf}$ is not used for model-level explanations, since including it would result in the model giving explanations that do not belong to class $C$.

# Evidence Given
- The proposed method of D4Explainer is evaluated with varying benchmarks and baselines.
  - D4Explainer's ability to provide both counterfactual and model-level explanations is evaluated on both node classification tasks alongside graph classification tasks. D4Explainer's performance is compared to the performance of other (counter)factual or model-level GNN explanation mechanisms.
  - 3 synthetic datasets and 1 real-world dataset for node classification are used, while 1 synthetic dataset and 3 real-world datasets are used for graph classification. All synthetic datasets regard classifications of nodes/graphs that belong to a certain type or shape of graphs, such as a cycle, tree, or house. All real-world datasets for graph classification regard the representation of molecules as graphs, with atoms represented as nodes.
  - For counterfactual explanations, the explanations must be tested on both the in-distribution property and the counterfactual property, in addition to their robustness and diversity. 
    - The counterfactual property is measured using three metrics: the counterfactual accuracy $CF-ACC$, which is the proportion of generated explanations that changed the model's prediction, the fidelity $FID$, which measures the change in output probability over the original class, and the modification ratio $MR$, which measures the proportion of edges that were added or deleted. 
    - The in-distribution property is evaluated using the maximum mean discrepancy $MMD$, which can be used to compare graph statistics between the generated counterfactual explanation and the original graph.
    - Robustness is measured using a Top-$K$ accuracy for counterfactual explanations that are classified correctly irrespective of noise being present in the graph: good counterfactual explanations should be classified consistently even when some noise is present.
    - Diversity is not measured, but evaluated qualitatively. It is shown that D4Explainer's ability to not only delete, but also create edges during the counterfactual explanation creation process, vastly improves D4Explainer's capability of generating diverse counterfactual explanations. The ability to create edges is novel and adds a new layer of diversity to D4Explainer.
  - Although model-level explanations are also evaluated qualitatively, a different set of benchmarks are considered: the probability $p$ given by the GNN that the explanation belongs to the correct class and the $Density$, which measures the density of edges over nodes in the explanation. A lower density implies a simpler graph, and thus a better explanation.
- The qualitative evaluations show that D4Explainer consistently performs best in providing counterfactual and model-level explanations.
  - For counterfactual explanations, D4Explainer scores the highest counterfactual accuracy and fidelity for 7 out of 8 datasets, reaching counterfactual accuracies of over 90%. D4Explainer seems to be a major improvement in the generation of counterfactual explanations for highly complex graphs. Additionally, D4Explainer consistently achieves the lowest $MMD$ measurements, implying that its counterfactual explanations are the most in-distribution.
  - For model-level explanations, D4Explainer consistently achieves better performance compared to the baseline. It produces model-level explanations that give greater predictions confidences $p$ by the model, while making these explanations be less dense and thus simpler.

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
- [44] [Conditional Diffusion Based on Discrete Graph Structures for Molecular Graph Generation](https://arxiv.org/pdf/2301.00427.pdf) (2023)
  - An example of conditional diffusion models used for the generation of in-distribution graphs.

# Impact
- See slides

# Reproducibility
- The source code for D4Explainer is publicly available at https://github.com/Graph-and-Geometric-Learning/D4Explainer. The code can be ran from the terminal and offers varying scripts that can be ran, such as training a GNN on a dataset, training a D4Explainer model on a dataset using a trained GNN, and evaluating a trained D4Explainer model.
- The paper includes hyperparameters for the GNNs and D4Explainer models that were evaluated.

# Conclusion
- See slides