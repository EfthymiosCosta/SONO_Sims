sono <- function(data, probs, alpha = 0.01, r = 2, MAXLEN = 0, frequent = FALSE){
  if (frequent){
    source('src/sono_freq.R')
    sono_out <- sono_freq(data, probs, alpha, r, MAXLEN)
  } else {
    source('src/sono_infreq.R')
    sono_out <- sono_infreq(data, probs, alpha, r, MAXLEN)
  }
  return(sono_out)
}
