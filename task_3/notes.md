# Workshop Multiple Imputation DOCtor (`midoc`)
Multiple Imputation (MI) has been around for a long time.
With the R package mice, it has become very easy to perform MI.
However, because it is so easy, people tend not to think about it too much.
Carefully performing MI is only a recent development.
The `midoc` package helps researchers and developers to come to the right imputation method.

## Why is `midoc` needed?
Most clinical and epidemiological datasets have data missing.
Imputating these datasets requires careful consideration
Clearly, there is a need for performing MI carefully.
`midoc` aims to help researchers with imputating responsibly.

## `midoc` Decision Making System
- Input dataset, specify analysis model & DAG
- Explore missing data patterns & mechanisms (`descMissData` and `exploreDAG`)
- Is CRA unbiased in principle and sufficiently precise (`checkCRA`)?
  - YES: Implement CRA
  - NO: Is (MAR) MI unbiased in principle (`checkMI`)?
    - YES: Implement suitable MI strategy (`checkModSpec`, `proposeMI`, `doMImice`)
    - NO: Suggest NARFCS, use of linked data, etc.

## Worked example
We simulate the `bmi` dataset in the `midoc` package.
We are interested in the variables "maternal age at first pregnancy" and "child's BMI at age 7".
We model these variables in a DAG and see that maternal age at first pregnancy --> child's BMI at age 7.
Maternal education is a confounder of these two variables.
"R" is a variable that indicates missingness of the child's BMI at age 7: 1 is no missing data, 0 is full missing data.
For these sorts of datasets, roughly 40% of the data may be missing most of the time.
We call DAGs with variables that measure missingness "mDAGs", which is one of the additions `midoc` makes to the MI process.

### Activity - explore missing data patterns and mechanisms
- Open a new R session
- Load the `midoc` package
- Open the shiny app using `midocVignette()`
- Reading through this vignette will guide you through the process of building an mDAG for your dataset.
  - You construct a DAG for your dataset using `dagitty`.
  - You can test if the mDAG is consistent with the data using the `exploreDAG()` function.

### Activity - checking whether CRA and MI are valid in principle
We explore whether Complete Records Analysis (CRA) and/or MI are valid in principle using the mDAG from the previous step.
In general, CRA will be biased unless we condition on maternal education.
Auxiliary variables need to be chosen carefully, avoiding colliders.
R has to be conditionally independent (d-separated) from the Outcome variable to be imputated.
Use the `checkMI()` function to explore whether MI would be valid in principle given your mDAG and predictors.

### Activity - implementing a suitable MI strategy
- Check the specification of your imputation model from the previous step
- Inspect the proposed `mice` call
- Perform MI using the proposed `mice` call
- Use steps 4 and 5 of the vignette to guide you

The imputation model for BMI at age 7 years requires a quadratic form of maternal age.
We can use the diagnostic plots in `proposeMI` to finetune our `mice` call if necessary.
The default in `mice` is a linear relationship between variables, not quadratic or otherwise.
In the plots provided by `proposeMI`, the blue box-and-whiskers plot shows the distribution of the observed data, and the red plots show the imputed distributions.
You can look at these plots to determine your satisfaction with the imputation.

# Seminar Selection bias, missing data and causal inference
### By Kate Tilling
Selection bias is often collider bias.
It can be caused by missing data/dropout, selection into study, and studying only a subgroup.
The latter has only gained relevancy recently.

No unmeasured confounders is often an implausible assumption.
Regression analysis is biased by selection and by confounding (unless adjusted for confounders).
When selection depends on exposure, regression analysis is *not* biased by selection, only by confounding if not adjusted.
However, in this case, instrumental variable (IV) analysis will be biased.
When selection depends on unmeasured causes of the outcome and the exposure, regression will be biased, but IV analysis will not.

UK Biobank is a study in the UK that recruited 500000 people aged between 40-69 years from across the country.
However, only 5% of those invited agreed to participate.
Biobank participants tend to differ from general population:
- Less likely  to be obese, to smoke, and to drink alcohol daily
- Fewer self-reported health conditions
- Rates of mortality and cancer were lower

We looked at different genetic exposures that may lead to people participating in the UK Biobank study.
We found that genetic correlation between participation in ALSPAC and Biobank was higher than a non-genetic baseline: different people in different studies were showed to be genetically alike just because they both participated in the studies.
We also found that people predisposed to a high BMI or depression were less likely to participate in tests involving physical/mental health, implying MNAR.

This has some implications for analyses (causal, predictive, explanatory).
- Adjust for variables associated with missingness.
- Use inverse probability weighting.
- Use imputation.

# Seminar Auxiliary imputation variables that only predict missingness can increase bias due to data missing not at random
### By Ellie Curnow
1. Resolve outstanding questions around bias due to incorrect specification of the imputation model, and how this differs by the type of variable imputed and the role of the variable in the analysis model.
2. Develop methodology to identify the optimum choice of variables to include and imputation model

In general, MI relies on the Missing At Random (MAR) assumption: the probability that data are missing is independent of the true values.
When we suspect that data are MNAR:
- Complete records analysis (CRA) may be valid
- Explore the sensitivity of MI results to departures from the MAR assumption
- Use auxiliary variables, see Cornish et al.'s Multiple imputation using linked proxy outcome data resulted in ...
  - We aim to reduce he bias due to data MNAR

When we have an auxiliary variables that is predictive of missingness, but not the outcome, avoid including it into the analysis model.
$\beta_{xy}$ denotes the parameter of interest from a regression Y on continuous variable X.
Z is related to R, but is not included in the analysis model.
X and Z are fully observed.
Both CRA and MI, imputating Y using X and Z will be biased.
The maximum additional bias will be dependent on the imputation rounds performed on X and on Z.
Essentially, bias gets worse as your XY relationship gets stronger.

A real data example is the Avon Longitudinal Study of Parents and Children (ALSPAC).
It is a substantive model: regression of child's IQ at age 15 years on breastfeeding duration.
Adjusting for six confounders of the breastfeeding-IQ relationship.
Analysis cohort is all singletons and twins.
IQ15 was not reported for 68% of participants.
We assessed whether the hypothetical DAG is plausible by exploring the observed relationships between the variables and applied the formula for maximum bias amplification.
We found that the estimated association between maternal smoking and IQ15 was -0.79.
The key thing when we look at the results is that, when adding an auxiliary variable in our analysis, we introduced a bias.
The message you should take from our talk is that: when you perform MI, you should not throw all auxiliary variables at the analysis model.
Pick and choose auxiliary variables carefully, respecting your knowledge, beliefs, and DAG.
