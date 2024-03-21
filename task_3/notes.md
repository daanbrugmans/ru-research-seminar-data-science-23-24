# Workshop Multiple Imputation DOCtor (`midoc`)
Multiple Imputation (MI) has been around for a long time.
With the R package mice, it has become very easy to perform MI.
However, because it is so easy, people tend not to think about it too much.
Carefully performing MI is only a recent development.
The `midoc` package helps researchers and developers to come to the right imputation method.

## Why is midoc needed?
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

## Activity - implementing a suitable MI strategy
- Check the specification of your imputation model from the previous step
- Inspect the proposed `mice` call
- Perform MI using the proposed `mice` call
- Use steps 4 and 5 of the vignette to guide you

The imputation model for BMI at age 7 years requires a quadratic form of maternal age.
We can use the diagnostic plots in `proposeMI` to finetune our `mice` call if necessary.
The default in `mice` is a linear relationship between variables, not quadratic or otherwise.
In the plots provided by `proposeMI`, the blue box-and-whiskers plot shows the distribution of the observed data, and the red plots show the imputed distributions.
You can look at these plots to determine your satisfaction with the imputation.

# Seminar Multiple Imputation DOCtor

