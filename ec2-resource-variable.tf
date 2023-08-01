#multiple AWS IAM users using loop function
variable "iamusers" {
  type    = list(string)
  default = ["drakun", "mickey", "izana", "south", "hanagaki", "sukuna", "satoru", "inusuke", "yuki", "shinichiro"]
}
