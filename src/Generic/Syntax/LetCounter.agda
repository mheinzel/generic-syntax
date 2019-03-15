module Generic.Syntax.LetCounter where

open import Algebra
open import Data.Bool
open import Data.Product
open import Data.List.Relation.Unary.All
open import Agda.Builtin.List
open import Agda.Builtin.Equality
open import Function

open import indexed
open import var
open import Generic.Syntax

import Generic.Syntax.LetBinder as LetBinder

data Counter : Set where
  zero : Counter
  one  : Counter
  many : Counter

_+_ : Counter → Counter → Counter
zero + n = n
m + zero = m
_ + _    = many

module _ {I : Set} where

  Count : List I → Set
  Count = All (λ _ → Counter)

  zeros : [ Count ]
  zeros = tabulate (λ _ → zero)

  fromVar : ∀ {i} → [ Var i ⟶ Count ]
  fromVar z     = one ∷ zeros
  fromVar (s v) = zero ∷ fromVar v

  merge : [ Count ⟶ Count ⟶ Count ]
  merge = curry (zipWith (uncurry _+_))

  rawMonoid : List I → RawMonoid _ _
  rawMonoid Γ = record
    { Carrier = Count Γ
    ; _≈_     = _≡_
    ; _∙_     = merge
    ; ε       = tabulate (λ _ → zero)
    }

module _ {I : Set} where

  Let : Desc I
  Let = `σ Counter $ λ _ → LetBinder.Let

pattern `IN' e t = (_ , e , t , refl)
pattern `IN  e t = `con (`IN' e t)

module _ {I : Set} {d : Desc I} where

  embed : ∀ {i σ} → [ Tm d i σ ⟶ Tm (d `+ Let) i σ ]
  embed = map^Tm (MkDescMorphism (true ,_))