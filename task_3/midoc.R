rm(list=ls())

library(midoc)
library(dagitty)

Sys.setenv(RSTUDIO_PANDOC="C:/Program Files/RStudio/resources/app/bin/quarto/bin/tools")
Sys.getenv("RSTUDIO_PANDOC")

midocVignette()

# Activity - explore missing data patterns and mechanisms
bmi <- midoc::bmi
descMissData(y="bmi7", covs="matage mated", data=bmi)
mdag <- "matage -> bmi7 mated -> matage mated -> bmi7 sep_unmeas -> mated sep_unmeas -> r"
exploreDAG(mdag, bmi)

# Activity - checking whether CRA and MI are valid in principle
    # Excluding confounder mated: CRA is invalid
checkCRA(y="bmi7", covs="matage", r_cra="r",mdag=mdag) 

    # Including confounder mated: CRA is valid
checkCRA(y="bmi7", covs="matage mated", r_cra="r",mdag=mdag) 
