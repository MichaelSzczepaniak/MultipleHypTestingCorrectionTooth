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
                          as.character(tooth.table[2,2])),
                     t2=c("Question 1.", "OJ1.0", "OJ2.0",
                          as.character(tooth.table[2,2]),
                          as.character(tooth.table[3,2])),
                     t3=c("Question 1.", "VC0.5", "VC1.0",
                          as.character(tooth.table[4,2]),
                          as.character(tooth.table[5,2])),
                     t4=c("Question 1.", "VC1.0", "VC2.0",
                          as.character(tooth.table[5,2]),
                          as.character(tooth.table[6,2])),
                     t5=c("Question 2.", "VC0.5", "OJ0.5",
                          as.character(tooth.table[4,2]),
                          as.character(tooth.table[1,2])),
                     t6=c("Question 2.", "VC1.0", "OJ1.0",
                          as.character(tooth.table[5,2]),
                          as.character(tooth.table[2,2])),
                     t7=c("Question 2.", "VC2.0", "OJ2.0",
                          as.character(tooth.table[6,2]),
                          as.character(tooth.table[3,2])))
    library(knitr)
    kable(df, digits=2)
}

## Returns the results of the 7 t-tests and evaluates the results against
## FPR (no correction), FWER (Bonferroni), and FDR (Benjamini Hochberg)
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
    t.fpr <- (t.pvals < alpha)
    t.fwer.q1 <- rejectBonferroni(t.pvals[1:4], alpha)$rejectH0
    t.fwer.q2 <- rejectBonferroni(t.pvals[5:7], alpha)$rejectH0
    t.fwer <- c(t.fwer.q1, t.fwer.q2)
    t.fdr.q1 <- rejectBenjHoch(t.pvals[1:4], alpha)$rejectH0
    t.fdr.q2 <- rejectBenjHoch(t.pvals[5:7], alpha)$rejectH0
    t.fdr <- c(t.fdr.q1, t.fdr.q2)
    t.test.num <- 1:7
    
    return(data.frame(test.num = 1:7, P_value = t.pvals,reject_FPR = t.fpr,
                      reject_FWER = t.fwer, reject_FDR = t.fdr))
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

## Returns a data frame with the p_values passed in as the p_values column
## and the rejectH0 column of boolean values designating whether the
## P-value was rejected (TRUE) or not (FALSE) under a Type II error rate
## alpha.
rejectBonferroni <- function(p_vals, alpha) {
    alpha.fwer <- alpha / length(p_vals)
    reject <- p_vals <= alpha.fwer
    result <- data.frame(p_values = p_vals, rejectH0 = reject)
    return(result)
}

## Ranks the p_values passed in and does a Benjamini Hochberg correction.
## A data frame with the following 4 columns is returned:
##
## test.id - test identifier, used tell which P-value corresponded to what test
## p.vals - passed in p_values in their original order
## alpha.bh.adj - BH adjusted alpha used to reject or accept H0
## rejectH0 - boolean values designating whether the P-value was rejected
##            (TRUE) or not (FALSE) under Type II error rate alpha.
rejectBenjHoch <- function(p_values, alpha) {
    suppressMessages(suppressWarnings(library(dplyr)))
    library(dplyr)
    result <- data.frame(test.id = 1:length(p_values), p.vals = p_values,
                         alpha.bh.adj = alpha)
    result <- mutate(result, rejectH0 = (p_values < alpha))
    result <- arrange(result, p.vals)
    m <- length(p_values)
    result$alpha.bh.adj <- alpha * (1:m) / m
    result$rejectH0 = (result$p.vals <= result$alpha.bh.adj)
    result$rank <- 1:m
    result <- arrange(result, test.id)  # put back in original order
    
    return(result)
}

