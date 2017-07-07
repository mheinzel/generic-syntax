\begin{code}
module Generic.Semantics where

open import Size
open import Data.Bool
open import Data.List.Base as L hiding ([_])
open import Data.Product as P hiding (,_)
open import Function
open import Relation.Binary.PropositionalEquality hiding ([_])

open import var
open import indexed
open import environment as E hiding (refl)
open import Generic.Syntax

module _ {I : Set} where

 Alg : (d : Desc I) (𝓥 𝓒 : I ─Scoped) → Set
 Alg d 𝓥 𝓒 = {i : I} → [ ⟦ d ⟧ (Kripke 𝓥 𝓒) i ⟶ 𝓒 i ]

module _ {I : Set} {d : Desc I} where
\end{code}
%<*comp>
\begin{code}
 _─Comp : List I → I ─Scoped → List I → Set
 (Γ ─Comp) 𝓒 Δ = {s : Size} {i : I} → Tm d s i Γ → 𝓒 i Δ
\end{code}
%</comp>
%<*semantics>
\begin{code}
record Sem {I : Set} (d : Desc I) (𝓥 𝓒 : I ─Scoped) : Set where
 field  th^𝓥   : {i : I} → Thinnable (𝓥 i)
        var    : {i : I} → [ 𝓥 i                   ⟶ 𝓒 i ]
        alg    : {i : I} → [ ⟦ d ⟧ (Kripke 𝓥 𝓒) i  ⟶ 𝓒 i ]
\end{code}
%</semantics>
%<*semtype>
\begin{code}
 sem   :  {Γ Δ : List I} → (Γ ─Env) 𝓥 Δ → (Γ ─Comp) 𝓒 Δ
 body  :  {Γ Δ : List I} {s : Size} → (Γ ─Env) 𝓥 Δ → ∀ Θ i → Scope (Tm d s) Θ i Γ → Kripke 𝓥 𝓒 Θ i Δ
\end{code}
%</semtype>
%<*sem>
\begin{code}
 sem ρ (`var k) = var (lookup ρ k)
 sem ρ (`con t) = alg (fmap d (body ρ) t)
\end{code}
%</sem>
%<*body>
\begin{code}
 body ρ []       i t = sem ρ t
 body ρ (_ ∷ _)  i t = λ σ vs → sem (vs >> th^Env th^𝓥 ρ σ) t
\end{code}
%</body>
%<*closed>
\begin{code}
 closed : ([] ─Comp) 𝓒 []
 closed = sem ε
\end{code}
%</closed>
\begin{code}
open import varlike
module _ {I : Set} where
\end{code}
%<*reify>
\begin{code}
 reify : {𝓥 𝓒 : I ─Scoped} → VarLike 𝓥 →
         {Γ : List I} → ∀ Δ i → Kripke 𝓥 𝓒 Δ i Γ → Scope 𝓒 Δ i Γ
 reify vl^𝓥 []         i b = b
 reify vl^𝓥 Δ@(_ ∷ _)  i b = b (freshʳ vl^Var Δ) (freshˡ vl^𝓥 _)
\end{code}

%</reify>
\begin{code}
 record Syntactic (d : Desc I) (𝓥 : I ─Scoped) : Set where
   field
     var    : {i : I} → [ 𝓥 i ⟶ Tm d ∞ i ]
     vl^𝓥  : VarLike 𝓥

   semantics : Sem d 𝓥 (Tm d ∞)
   Sem.var   semantics = var
   Sem.th^𝓥  semantics = th^𝓥 vl^𝓥
   Sem.alg   semantics = `con ∘ fmap d (reify vl^𝓥)

module _ {I : Set} {d : Desc I} where

 sy^Var : Syntactic d Var
 Syntactic.var    sy^Var = `var
 Syntactic.vl^𝓥  sy^Var = vl^Var
\end{code}
%<*renaming>
\begin{code}
 Renaming : Sem d Var (Tm d ∞)
 Renaming = record
   { th^𝓥  = λ k ρ → lookup ρ k
   ; var   = `var
   ; alg   = `con ∘ fmap d (reify vl^Var) }

 ren :  {Γ Δ : List I} → (Γ ─Env) Var Δ →
        (Γ ─Comp) (Tm d ∞) Δ
 ren = Sem.sem Renaming
\end{code}
%</renaming>
\begin{code}
 th^Tm : {i : I} → Thinnable (Tm d ∞ i)
 th^Tm t ρ = Sem.sem Renaming ρ t

 vl^Tm : VarLike (Tm d ∞)
 new   vl^Tm = `var z
 th^𝓥  vl^Tm = th^Tm

 sy^Tm : Syntactic d (Tm d ∞)
 Syntactic.var   sy^Tm = id
 Syntactic.vl^𝓥  sy^Tm = vl^Tm

\end{code}
%<*substitution>
\begin{code}
 Substitution : Sem d (Tm d ∞) (Tm d ∞)
 Substitution = record
   { th^𝓥  = λ t ρ → ren ρ t
   ; var   = id
   ; alg   = `con ∘ fmap d (reify vl^Tm) }

 sub :  {Γ Δ : List I} → (Γ ─Env) (Tm d ∞) Δ →
        (Γ ─Comp) (Tm d ∞) Δ
 sub = Sem.sem Substitution
\end{code}
%</substitution>