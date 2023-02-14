terraform {
  cloud {
    organization = "mtcterraform"

    workspaces {
      name = "mtc-dev"
    }
  }
}