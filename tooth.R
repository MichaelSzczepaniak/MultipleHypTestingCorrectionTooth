loadToothData <- function() {
    suppressMessages(suppressWarnings(require(dplyr)))
    library(datasets)
    library(dplyr)
    data("ToothGrowth")
    # rename variables/columns to make them clearer
    tooth.data <- rename(ToothGrowth, Length=len, Delivery=supp, Dose=dose)
    # add group id
    tooth.data <- mutate(tooth.data,
                         Group=factor(paste0(Delivery, sprintf("%.1f", Dose))))
    tooth.data <- mutate(tooth.data,  Dose = factor(Dose))
    return(tooth.data)
}

getToothSummary <- function(tooth.data = loadToothData()) {
    library(dplyr)
    tooth.summ <- group_by(tooth.data, Group)
    tooth.table <- summarize(tooth.summ, Mean.Length = mean(Length),
                             Std.Dev.Length = sd(Length))
    library(knitr)
    kable(tooth.table, digits=2)
}

exploreBox <- function(tooth.data = loadToothData()) {
    library(ggplot2)
    # exploratory panel plot
    p <- ggplot(tooth.data, aes(Dose, Length))
    p <- p + geom_boxplot()
    p <- p + facet_grid(Delivery ~ .)
    p <- p + xlab("Dose (milligrams)") + ylab("Length (units unknown)")
    p <- p + ggtitle("Effect of Vitamin C on Tooth Growth in Guinea Pigs")
    print(p)
}




# create summary table of Length means
tooth.summ <- group_by(tooth.data, Delivery, Dose)
tooth.table <- summarize(tooth.summ, Mean.Length = mean(Length),
                         Std.Dev.Length = sd(Length))
print(tooth.table)

## old way to create the hypothesis testing table
createTestingTable <- function() {
    df <- data.frame(Test=c("Addresses", "Group A", "Group B"),
                     t1=c("Question 1.", "OJ0.5", "OJ1.0"),
                     t2=c("Question 1.", "OJ1.0", "OJ2.0"),
                     t3=c("Question 1.", "VC0.5", "VC1.0"),
                     t4=c("Question 1.", "VC1.0", "VC2.0"),
                     t5=c("Question 2.", "OJ0.5", "VC0.5"),
                     t6=c("Question 2.", "OJ1.0", "VC1.0"),
                     t7=c("Question 2.", "OJ2.0", "VC2.0"))
    library(knitr)
    kable(df)
}

## Creates the hypothesis testing table
createTestingTable <- function(tooth.data = loadToothData()) {
    suppressMessages(suppressWarnings(library(dplyr)))
    suppressMessages(suppressWarnings(library(knitr)))
    library(dplyr)
    tooth.summ <- group_by(tooth.data, Group)
    tooth.table <- summarize(tooth.summ, Mean.Length = mean(Length),
                             Std.Dev.Length = sd(Length))
    df <- data.frame(Test=c("Addresses", "Group A", "Group B", "Mean A", "Mean B"),
                     t1=c("Question 1.", "OJ0.5", "OJ1.0",
                          as.character(tooth.table[1,2]),
                          as.character(tooth.table[1,2])),
                     t2=c("Question 1.", "OJ1.0", "OJ2.0",
                          as.character(tooth.table[1,2]),
                          as.character(tooth.table[1,2])),
                     t3=c("Question 1.", "VC0.5", "VC1.0",
                          as.character(tooth.table[1,2]),
                          as.character(tooth.table[1,2])),
                     t4=c("Question 1.", "VC1.0", "VC2.0",
                          as.character(tooth.table[1,2]),
                          as.character(tooth.table[1,2])),
                     t5=c("Question 2.", "OJ0.5", "VC0.5",
                          as.character(tooth.table[1,2]),
                          as.character(tooth.table[1,2])),
                     t6=c("Question 2.", "OJ1.0", "VC1.0",
                          as.character(tooth.table[1,2]),
                          as.character(tooth.table[1,2])),
                     t7=c("Question 2.", "OJ2.0", "VC2.0",
                          as.character(tooth.table[1,2]),
                          as.character(tooth.table[1,2])))
    library(knitr)
    kable(df)
}

## Returns the results of the 7 t-tests
getTestResults <- function(tooth.data = loadToothData(),
                           alpha = 0.05) {
    t.pvals <- vector(mode = "numeric", length = 7)
    t.logic <- vector(mode = "logical", length = 7)
    # test dosages
    binary.data <- filter(tooth.data, Group == "OJ0.5" | Group == "OJ1.0")
    t.pvals[1] <- getPvalue(binary.data)
    binary.data <- filter(tooth.data, Group == "OJ1.0" | Group == "OJ2.0")
    t.pvals[2] <- getPvalue(binary.data)
    binary.data <- filter(tooth.data, Group == "VC0.5" | Group == "VC1.0")
    t.pvals[3] <- getPvalue(binary.data)
    binary.data <- filter(tooth.data, Group == "VC1.0" | Group == "VC2.0")
    t.pvals[4] <- getPvalue(binary.data)
    # test delivery
    binary.data <- filter(tooth.data, Group == "VC0.5" | Group == "OJ0.5")
    t.pvals[5] <- getPvalue(binary.data, FALSE)
    binary.data <- filter(tooth.data, Group == "VC1.0" | Group == "OJ1.0")
    t.pvals[6] <- getPvalue(binary.data, FALSE)
    binary.data <- filter(tooth.data, Group == "VC2.0" | Group == "OJ2.0")
    t.pvals[7] <- getPvalue(binary.data, FALSE)
    # rejection test
    t.logic <- (t.pvals < alpha)
    
    return(data.frame(P_value = t.pvals, reject_H0 = t.logic))
}

## Evaluates t-test results for Dose and Delivery under unequal group variances
getPvalue <- function(test.data, testDose = TRUE) {
    pval <- NULL
    if(testDose) {
        pval <- t.test(Length ~ Dose, paired = FALSE, var.equal = FALSE,
                       data = test.data)$p.value
    } else {
        pval <- t.test(Length ~ Group, paired = FALSE, var.equal = FALSE,
                       data = test.data)$p.value
    }
    
    return(pval)
}