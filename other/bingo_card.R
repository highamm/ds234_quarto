## https://gist.github.com/dsparks/e246a90c7a1347e81ee5a492bfad7026

library(ggplot2)

new_theme_empty <- theme_bw()
new_theme_empty$line <- element_blank()
new_theme_empty$rect <- element_blank()
new_theme_empty$strip.text <- element_blank()
new_theme_empty$axis.text <- element_blank()

nCards <- 3
ruleText <- c("Look for these on the field, in the stands, or in the commercials.\n\"\" indicate that you should listen for the broadcast team to say this phrase.")
freeSpaceText <- "Hyperbole"
wordList <- c("Forgot to re-read data set",  # The \n indicates a newline,
              "Missing )",      # so you can insert linebreaks where appropriate.
              "Missing \" ",
              "capitalization error",     # And \" allows you to insert a quotation mark.
              "Forgot to load library",
              "Missing Pipe",
              "Missing `ggplot` + Sign",
              "Missing `mutate()`",
              "Rendering Error",
              "Fumble",
              "Interception",
              "Fourth-down\nconversion",
              "Blocked kick",
              "Blocked punt",
              "Onside kick",
              "QB Sack",
              "First down",
              "\"Rung his\nbell\"",
              "Intentional\ngrounding",
              "\"We talked\nabout\"",
              "Gatorade",
              "Horse in a\ncommercial",
              "Talking\nanimal",
              "Foam finger",
              "Painted face",
              "Player's\nspouse",
              "Owner's\nreaction",
              "RB scores\ntouchdown",
              "QB scores\ntouchdown",
              "WR scores\ntouchdown",
              "Defense scores\ntouchdown",
              "Holding",
              "Offsides",
              "Flea-flicker",
              "Non-QB\npass",
              "Fair catch",
              "Challenge\nflag",
              "Successful\nchallenge",
              "Unsuccessful\nchallenge",
              "Pass\ninterference",
              "Car\ncommercial",
              "Beer\ncommercial",
              "Soda\ncommercial",
              "Candy\ncommercial",
              "30+ yard\nreception",
              "10+ yard\nreception",
              "30+ yard\nrun",
              "10+ yard\nrun",
              "5+ yard\nrun",
              "Coach throws\nheadset",
              "Crying\nplayer",
              "Field goal",
              "Incomplete\npass",
              "2-point\nconversion",
              "False start",
              "Roger\nGoodell",
              "\"Take care\nof the\nfootball\"",
              "\"Chip shot\"",
              "\"Splits the\nuprights\"",
              "Icing the\nkicker",
              "\"Two-minute\ndrill\"",
              "\"Milk the\nclock\"",
              "Pick-six",
              "\"Second effort\"",
              "\"Field\nposition\"",
              "\"Shaken up\"",
              "Taking a\nknee",
              "Public service\nannouncement")

# Loop
for(ii in 1:nCards){
  randomWords <- sample(wordList, 25)
  randomWords[13] <- freeSpaceText
  plotFrame <- data.frame(x = rep(1:5, 5), y = rep(1:5, each = 5), randomWords)
  plotFrame$bgColor <- runif(25, 0.9, 1)

  zp1 <- ggplot(plotFrame)
  zp1 <- zp1 + geom_rect(xmin = 2.5, xmax = 3.5,
                         ymin = 2.5, ymax = 3.5,
                         fill = gray(10/11), lty = 3)
  zp1 <- zp1 + geom_rect(aes(xmin = x - 1/2, xmax = x + 1/2,
                             ymin = y - 1/2, ymax = y + 1/2),
                         fill = "transparent",
                         colour = gray(2/3))
  zp1 <- zp1 + geom_text(aes(x = x, y = y, label = randomWords),
                         size = 4)
  zp1 <- zp1 + coord_equal() + new_theme_empty
  zp1 <- zp1 + scale_fill_identity()
  zp1 <- zp1 + ggtitle("Super Bowl bingo",
                       subtitle = ruleText)
  zp1 <- zp1 + scale_x_continuous("", limits = c(0.25, 5.75), breaks = 1:5-1/2)
  zp1 <- zp1 + scale_y_continuous("", limits = c(0.25, 5.75), breaks = 1:5-1/2)
  zp1 <- zp1 + theme(axis.title.x=element_text(size = rel(8/9)))
  ggsave(plot = zp1, paste0("Super Bowl bingo card ", ii, ".png"),
         type = "cairo-png", h = 10, w = 7.5)
}
