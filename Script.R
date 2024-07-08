#####################
#Kevin Corfield
#Universidad de Buenos Aires 
#Local Projections
#####################
library(lmtest)
library(sandwich)
library(ivreg)
library(dynlm)
library(haven)
library(ggplot2)
library(readxl)
Data_LP <- read_excel("C:/Users/Kevin/Desktop/Data_LP.xlsx")
View(Data_LP)

# Preparar la data
df <- Data_LP
df <- df[,-1]

df$EMAE <- as.numeric(df$EMAE)
df$IPC <- as.numeric(df$IPC)
df$TC <- as.numeric(df$TC)

##############################################################
#Brecha de producto
##############################################################
library(seasonal)
library(mFilter)

#Convierto a ts
emae <- ts(df$EMAE, start = c(2004,1), frequency = 12)
#Desestacionalizo
emae_uns <- seas(emae)

#HP Filter
emae_hp <- hpfilter(emae_uns$data[,1], type="lambda", freq=14400 ,drift=TRUE)
df$outputgap <- emae_hp$cycle

###############################################################
# Variación del tipo de cambio
###############################################################

df$vtc <- c(rep(NA,1), diff(log(df$TC)))

###############################################################
# Tasa de inflación acumulada
###############################################################

hmax=12

for (h in 1:hmax) {
  nm <- paste("infl", h-1, sep = "")
  # Calculate the log difference with the specified lag
  infl_diff <- diff(log(df$IPC), lag=h)
  # Create a vector of NA values to match the length of the original data
  infl_diff_padded <- c(rep(NA, h), infl_diff)
  # Assign the new column to the data frame
  df[[nm]] <- infl_diff_padded
}

df <- df[-1,]
###############################################################
# Local Projections by OLS
###############################################################
df <- ts(df, start = c(2004,1), frequency = 12)
bh <- matrix(nrow = hmax, ncol = 3)

for (h in 1:hmax) {
  
  reg <- dynlm(df[,ncol(df)-hmax+h] ~ vtc + L(vtc, 1:2) + L(outputgap, 1:2)  +
                 L(infl0, 1:2),
               data = df)  
  
  coefs=coeftest(reg, vcov=NeweyWest(reg, lag = h, prewhite = FALSE, adjust = T))
  
  #Store coefficient of DFF
  bh[h,1] = reg$coefficients[[2]]
  
  #Store Upper and Lower bands 90% confidence Bands
  bh[h,2] <- bh[h,1] + 1.645 * coefs[2,2]
  bh[h,3] <- bh[h,1] - 1.645 * coefs[2,2]
}


# Crear un data frame para los resultados
df_plot <- data.frame(
  Horizon = 1:hmax,
  ERPT = bh[, 1],
  UpperBand = bh[, 2],
  LowerBand = bh[, 3]
)

# Graficar los resultados con ggplot2
ggplot(df_plot, aes(x = Horizon)) +
  geom_line(aes(y = ERPT, color = "ERPT"), size = 1.2, show.legend = FALSE) +
  geom_ribbon(aes(ymin = LowerBand, ymax = UpperBand), alpha = 0.2, show.legend = FALSE) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "black") +
  labs(title = "Pass-Through del Tipo de Cambio (ERPT)",
       x = "Horizonte (meses)",
       y = "ERPT acumulado") +
  scale_x_continuous(breaks = 1:hmax) +
  theme_minimal()
