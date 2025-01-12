#! perl

use warnings;
use strict;

my $f = shift or die "need fst file\n";
my $c1 = shift or die "need start coord\n";
my $windth = shift;
my $height = shift;
$height = $height * 2;
my $c2 = $c1 +1;
&plot_d($f);
sub plot_d{
    my $file = shift @_;
    open R,'>',"$file.R" or die "$!";
    print R "library(patchwork)
library(ggplot2)
library(tidyr)
data <- read.table(\"$file\")
colnames(data) <- c(\"chr\",\"start\",\"end\",\"var_num\",\"w_fst\",\"m_fst\")
data\$group <- findInterval(data\$var_num,seq(1,".$c1.",1))
res <- data.frame(i = seq(1,".$c2.",1),s = 0,r=0)
a_s <- sum(data\$var_num)

for(i in seq(1,".$c2.",1)){
  tmp_d <- data[data\$group == i,]
  tmp_s <- sum(tmp_d\$var_num)
  tmp_r <- tmp_s/a_s
  res[i,2] = tmp_s
  res[i,3] = tmp_r
}
res\$c_r <- cumsum(res\$r)
a <- ggplot(res)+
  geom_line(aes(x=i,y=c_r))+
  xlab(\"var_num_in_window\")+
  ylab(\"cumulative_percentage\")+
  scale_x_continuous(breaks = seq(0,".$c1.",10))+
  scale_y_continuous(breaks = seq(0,1,0.1))+
  theme_bw()
b <- ggplot(data,aes(x=var_num))+
  geom_histogram(binwidth = 1,colour= \"black\",position = \"identity\",boundary=0)+
  scale_x_continuous(breaks = seq(0,50,5),limits = c(0,50))+
  theme_bw()
d = a/b
ggsave(\"$file.density.snp_num.pdf\",d,width = $windth,height = $height)
e <- ggplot(data,aes(x=w_fst))+
  geom_histogram(binwidth = 0.01,colour= \"black\",position = \"identity\",boundary=0)+
  theme_bw()+
  theme(
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank()
  )+
  scale_x_continuous(
    breaks = c(
      seq(0,1,0.5),
      round(as.numeric(quantile(data\$w_fst,probs = c(0.99))),2),
      round(as.numeric(quantile(data\$w_fst,probs = c(0.95))),2)
      )
  )+
  geom_vline(aes(xintercept = quantile(w_fst,probs = c(0.99))),colour=\"firebrick3\",size=0.4,alpha = 2/3,linetype=\"dashed\")+
  geom_vline(aes(xintercept = quantile(w_fst,probs = c(0.95))),colour=\"navy\",size=0.4,alpha = 2/3,linetype=\"dashed\")
ggsave(\"$file.density.fst_value.pdf\",e,width = $windth,height = $height)\n";
    close R;
    `Rscript $file.R`;
}
