# Uncertainty propagation according to GUM

La propagazione dell'incertezza è stata effettuata assumendo assenza di correlazione tra i parametri.

L'odometria viene realizzata attraverso un sensore giroscopico, che fornisce la *velocità angolare* $\overrightarrow{ω}$ e un accelerometro che fornisce l'*accelerazione* $\overrightarrow{a}$, entrambe in un sistema di riferimento tredimensionale, di questi vettori, tuttavia, ci siamo occupati solo delle componenti lungo le direzioni di interesse, ovvero le componenti lungo l'asse $x$ e $z$.

La posizione lungo l'asse $x$ del robot in un istante $n\cdot dt$ può essere ottenuta a partire dalla seguente:

$$ x_{n} = x_{n-1} + v_{n-1}^x dt+\frac{1}{2} a_{n-1}^{x} dt^{2} $$

dove:

$$ v_{n}^{x} = v_{n} \cos(\theta_{n}) $$

$$ a_{n}^{x} = a_{n} \cos(\theta_{n}) $$

$$ \theta_{n} = \theta_{n-1} + \omega_{n-1}dt$$

Quindi sostituendo nella prima otteniamo:

$$ x_{n} = x_{n-1} + v_{n-1} \cos(\theta_{n-1})dt+\frac{1}{2} a_{n-1}\cos(\theta_{n-1})dt^{2} $$

$$ x_{n} = x_{n-1} + v_{n-1} \cos( \theta_{n-2} + \omega_{n-2}dt)dt+\frac{1}{2} a_{n-1}\cos( \theta_{n-2} + \omega_{n-2}dt)dt^{2} $$

Sostituiamo inoltre la seguente equazione:

$$ v_{n-1} = v_{n-2} + a_{n-2}dt ⇒ x_{n} = x_{n-1} +  (v_{n-2} + a_{n-2}dt) \cos( \theta_{n-2} + \omega_{n-2}dt) dt+\frac{1}{2} a_{n-1}cos( \theta_{n-2} + \omega_{n-2}dt)dt^{2} $$

$$  x_{n} = x_{n-1} +  (v_{n-2}dt + \frac{3}{2}a_{n-2}dt^{2} ) \cos( \theta_{n-2} + \omega_{n-2}dt)  $$

A cui possiamo applicare la formula per la propagazione delle incertezze secondo la GUM.

$$ \sigma_{y}^{2} = ∑_{i}\left(\left( \frac{\partial y}{\partial x_{i}}\right)^{2}\sigma_{i}^{2} \right) $$

Cominciamo scrivendo tutti i termini della sommatoria:

$$ \left( \frac{\partial x_{n}}{\partial x_{n-1}}\right)^{2}\sigma_{x_{n-1}}^{2} = \sigma_{x_{n-1}}^{2} $$

$$ \left( \frac{\partial x_{n}}{\partial v_{n-2}}\right)^{2}\sigma_{v_{n-2}}^{2} = dt^{2}\cos^{2}(\theta_{n-2} + \omega_{n-2}dt)\sigma_{v_{n-2}}^{2} $$

$$ \left( \frac{\partial x_{n}}{\partial a_{n-2}}\right)^{2}\sigma_{a_{n-2}}^{2} = \frac{9}{4}dt^{4}\cos^{2}(\theta_{n-2} + \omega_{n-2}dt)\sigma_{a}^{2} $$

$$ \left( \frac{\partial x_{n}}{\partial \theta_{n-2}}\right)^{2}\sigma_{\theta_{n-2}}^{2} = (v_{n-2}dt + \frac{3}{2}a_{n-2}dt^{2})^{2} \sin^{2}( \theta_{n-2} + \omega_{n-2}dt)\sigma_{\theta_{n-2}}^{2} $$

$$ \left( \frac{\partial x_{n}}{\partial \omega_{n-2}}\right)^{2}\sigma_{\omega}^{2} = dt^{2}(v_{n-2}dt + \frac{3}{2}a_{n-2}dt^{2})^{2} \sin^{2}( \theta_{n-2} + \omega_{n-2}dt)\sigma_{\omega}^{2} $$

In queste equazioni compaiono tre termini inediti: $\sigma_{x_{n-1}}^{2}$ che rappresenta semplicemente il risultato della stessa propagazione nell'istante precedente, $\sigma_{v_{n-2}}^{2}$ e $\sigma_{\theta_{n-2}}^{2}$, che si ricavano propagando l'incertezza rispettivamente nell'equazione per $v_{n}$ e $\theta_{n}$:

$$\sigma_{v_{n}}^{2} = \sigma_{v_{n-1}}^{2} + \sigma_{a}dt^{2}$$

$$\sigma_{\theta_{n}}^{2} = \sigma_{\theta_{n-1}}^{2} + \sigma_{\omega}dt^{2}$$

Si ottiene quindi l'incertezza su $x_{n}$:

$$\sigma_{x_{n}} = [\sigma_{x_{n-1}}^{2} + dt^{2}\cos^{2}(\theta_{n-2} + \omega_{n-2}dt)(\sigma_{v_{n-3}}^{2} + \sigma_{a}dt^{2}) +\frac{9}{4}dt^{4}\cos^{2}(\theta_{n-2} + \omega_{n-2}dt)\sigma_{a}^{2}+  $$

$$ + (v_{n-2}dt + \frac{3}{2}a_{n-2}dt^{2})^{2} \sin^{2}( \theta_{n-2} + \omega_{n-2}dt)( \sigma_{\theta_{n-3}}^{2} + \sigma_{\omega}dt^{2}) + dt^{2}(v_{n-2}dt + \frac{3}{2}a_{n-2}dt^{2})^{2} \sin^{2}( \theta_{n-2} + \omega_{n-2}dt)\sigma_{\omega}^{2}]^{\frac{1}{2}}$$
