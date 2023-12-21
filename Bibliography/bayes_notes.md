# Bayes theorem in sensor fusion

## Likelihood function (funzione di verosimiglianza)

Con la distribuzione di probabilità (pdf), cerchiamo di modellizzare un fenomeno attraverso dei parametri, in modo da estrarre la probabilità che un certo evento possa avvenire. La funzione di verosimiglianza, invece, permette di ricavare la distribuzione di probabilità (quindi i parametri) a partire dalla probabilità con cui essi si sono verificati.

- "Se lancio 100 volte una moneta non truccata, qual è la *probabilità* che esca sempre testa?"
- "Ho lanciato 100 volte una moneta non truccata ed è uscita 100 volte testa, qual è la *verosimiglianza* che la moneta sia truccata?"

$$ P(T)=\lambda=0.5, P(C)=1-λ ⇒ P(T,T) = P(T)P(T)=λ^{2}=0.25 ⇒\mathcal{L}(λ=0.5|T,T)$$

$$ P(T,T,C) = P(T)P(T)P(C)=λ^{2}(1-λ) ⇒\mathcal{L}(λ=0.5|T,T,C)=λ^{2}(1-λ)  $$

È possibile utilizzare questo approccio per ricostruire i parametri della pdf a partire dalla funzione di verisimiglianza, infatti, i parametri reali della funzione di verisimiglianza sono quelli che *massimizzano* la funzione.

In altre parole "Quanto e verisimile che il valore effettivo del misurando $x$ sia uguale alla misura $m$, se la lettura è $z$?

$$Consideriamo\ il\ modello\ dello\ strumento\ P(z) = norm(m,σ) = \frac{1}{σ\sqrt{2\pi}}e^{\frac{(z-m)^2}{2\sigma^2}}$$

In questo caso voglio massimizzare la funzione di verosimiglianza in relazione a $z$, cioè voglio trovare il valore $z$ che rende massima la verosimiglianza che $m=x$:

$$\mathcal{L}(m=x|z)=\frac{1}{σ\sqrt{2\pi}}e^{\frac{(z-x)^2}{2\sigma^2}}$$

($\mathcal{L}$ e $P$ coincidono per una proprietà della distribuzione normale)

$$\log\left(\mathcal{L}\right) = \log\left(\frac{1}{σ\sqrt{2\pi}}\right)⋅\log\left(e^{\frac{(z-x)^2}{2\sigma^2}}\right) = 0 $$

$$\frac{d\mathcal{L}}{dx}=\frac{2(z-x)}{2\sigma^2} = 0 ⇒z = x  $$

Cioè la massima verosimiglianza che $x = m$ si ha se $z = x$.

## Bayes in sensor fusion

### Bayes theorem

$$ P(x|z)P(z) = P(z|x)P(X) ⇒  P(x|z) = \frac{P(z|x)P(X)}{P(z)} $$

Dove, nel caso di una misura:

- $x$ è la stima del misurando,
- $z$ è la lettura dello strumento,
- $P(z|x)$ è il modello dello strumento,
- $P(x)$ è un'ipotesi a priori  sul misurando (*prior*, ad esempio ipotizzo che la massima differenza tra due misurazioni consecutive sia $30$),
- $P(z)$ normalizza la probabilità $P(x|z)$,
- $P(x|z)$ è la probabilità che la stima sia $x$ se ho letto $z$,

Il teorema di Bayes permette quindi di:

1. introdurre ipotesi a priori sul misurando,
2. combinare più letture: $P(x|z_{1},...,z_{n})$ è difficile da calcolare,  mentre facilmente:

$$ P(z_{1},...,z_{n}|x) = \prod_{i=1}^{n}P(z_{i}|x) ⇒P(x|\mathbf{z}) = \frac{P(x)}{P(\mathbf{z})}\prod_{i=1}^{n}P(z_{i}|x)=cP(x)\prod_{i=1}^{n}P(z_{i}|x)$$

Applichiamo delle $P(z_{i}|x)$ normali:

$$ P(x|z) = cP(x)\prod_{i=1}^{n}\left(\frac{1}{σ\sqrt{2\pi}}e^{\frac{(z-x)^2}{2\sigma^2}}\right) $$

- se $P(x)$ ipotesi a priori è una distribuzione *uniforme*:
- se $P(x)$ ipotesi a priori è una distribuzione *normale*:
