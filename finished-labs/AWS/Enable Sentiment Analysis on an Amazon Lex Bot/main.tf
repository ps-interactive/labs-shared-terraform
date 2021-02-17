resource "aws_iam_service_linked_role" "lexbots" {
  aws_service_name = "lex.amazonaws.com"
}


resource "aws_lex_slot_type" "product_types" {
  description = "Promotional Product Types"

  enumeration_value {
    value = "Clothing"
  }

  enumeration_value {
    value = "Footwear"
  }

  enumeration_value {
    value = "Bag"
  }

  enumeration_value {
    value = "Equipment"
  }

  enumeration_value {
    value = "Travel"
  }

  name                     = "ProductType"
  value_selection_strategy = "ORIGINAL_VALUE"
}

resource "aws_lex_intent" "signup" {

  conclusion_statement {
    message {
      content      = "Thank you for choosing the new {ProductType} promotional product from Carved Fitness. A confirmation email is sent to {email}"
      content_type = "PlainText"
    }
  }

  description = "Intent to allow users to signup"

  fulfillment_activity {
    type = "ReturnIntent"
  }

  name = "signup"

  sample_utterances = [
    "I would like to sign up for the promotional event",
    "I would like to sign up",
    "I need the new product",
    "I would like to receive the new product",
  ]

  slot {
    name     = "email"
    priority = 1

    slot_constraint = "Required"
    slot_type       = "AMAZON.EmailAddress"

    value_elicitation_prompt {
      max_attempts = 2

      message {
        content      = "Please provide the email address"
        content_type = "PlainText"
      }
    }
  }


  slot {
    description       = "Promotional Product Types"
    name              = "ProductType"
    priority          = 2
    slot_constraint   = "Required"
    slot_type         = aws_lex_slot_type.product_types.name
    slot_type_version = aws_lex_slot_type.product_types.version

    value_elicitation_prompt {
      max_attempts = 2

      message {
        content      = "Please choose the product type - clothing, footwear, equipment, bags, travel"
        content_type = "PlainText"
      }
    }
  }
}

resource "aws_lex_bot" "carved_rock_fitness_bot" {
  abort_statement {
    message {
      content_type = "PlainText"
      content      = "Sorry, I am not able to assist at this time"
    }
  }

  child_directed = false

  clarification_prompt {
    max_attempts = 2

    message {
      content_type = "PlainText"
      content      = "Sorry, what can I help you with?"
    }
  }

  description                 = "Carved Rock Fitness App"
  detect_sentiment            = false
  idle_session_ttl_in_seconds = 300

  intent {
    intent_name    = aws_lex_intent.signup.name
    intent_version = aws_lex_intent.signup.version
  }

  locale           = "en-US"
  name             = "CarvedRockFitnessBot"
  process_behavior = "SAVE"
  voice_id         = "Salli"
}

