![banner](/images/matsim-icon.png)

# Matsim&nbsp;&nbsp;![logo](https://img.shields.io/badge/license-MIT-blue.svg)

> A sleek, intuitive interface for building Simulink models from a Matlab script.

## What is it

Matsim is a high level interface to create Simulink models from a [Matlab](https://www.mathworks.com/) script. Matsim is a wrapper around the standard [simulink API](https://it.mathworks.com/help/simulink/ug/approach-modeling-programmatically.html) that makes building a simulink model programmatically much faster.

## Key features
* **Automatic layout** (no need to specify block positions!)
* **Intuitive interface** (you can "add", "subtract", "multiply", ... simulink blocks)
* **Extensible library** (easily add new blocks from your custom libraries)

<table>
<tr>
<th>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</th>
<th>With Matsim</th>
<th>With simulink API</th>
</tr>
<tr>
<th>Create or load model</th>
<td valign="top">
<pre class="language-matlab"><code class="language-matlab">sys <span class="token operator">=</span> simulation<span class="token punctuation">.</span><span class="token function">load</span><span class="token punctuation">(</span><span class="token string">'my_model'</span><span class="token punctuation">)</span><span class="token punctuation">;</span>
sys<span class="token punctuation">.</span><span class="token function">show</span><span class="token punctuation">(</span><span class="token punctuation">)</span></code></pre>
</td>
<td valign="top">
<pre class="language-matlab"><code class="language-matlab">sys <span class="token operator">=</span> <span class="token function">new_system</span><span class="token punctuation">(</span><span class="token string">'my_model'</span><span class="token punctuation">)</span><span class="token punctuation">;</span>
<span class="token function">open_system</span><span class="token punctuation">(</span>sys<span class="token punctuation">)</span><span class="token punctuation">;</span></code></pre>
</td>
</tr>
<tr>
<th>Add blocks</th>
<td valign="top">
<pre class="language-matlab"><code class="language-matlab">Vx <span class="token operator">=</span> <span class="token function">FromWorkspace</span><span class="token punctuation">(</span><span class="token string">'V_x'</span><span class="token punctuation">)</span><span class="token punctuation">;</span>
c <span class="token operator">=</span> <span class="token function">Constant</span><span class="token punctuation">(</span><span class="token number">1</span><span class="token punctuation">)</span><span class="token punctuation">;</span>
res <span class="token operator">=</span> Vx<span class="token operator">+</span>c<span class="token punctuation">;</span></code></pre>
</td>
<td>
<pre class="language-matlab"><code class="language-matlab"><span class="token function">add_block</span><span class="token punctuation">(</span><span class="token string">'simulink/Sources/From Workspace'</span><span class="token punctuation">,</span><span class="token string">'my_model/From Workspace'</span><span class="token punctuation">)</span><span class="token punctuation">;</span>
<span class="token function">set_param</span><span class="token punctuation">(</span><span class="token string">'my_model/From Workspace'</span><span class="token punctuation">,</span><span class="token string">'VariableName'</span><span class="token punctuation">,</span><span class="token string">'V_x'</span><span class="token punctuation">)</span>
<span class="token function">add_block</span><span class="token punctuation">(</span><span class="token string">'simulink/Sources/Constant'</span><span class="token punctuation">,</span><span class="token string">'my_model/Constant'</span><span class="token punctuation">)</span><span class="token punctuation">;</span>
<span class="token function">set_param</span><span class="token punctuation">(</span><span class="token string">'my_model/Constant'</span><span class="token punctuation">,</span><span class="token string">'Value'</span><span class="token punctuation">,</span><span class="token string">'1'</span><span class="token punctuation">)</span>
<span class="token function">add_block</span><span class="token punctuation">(</span><span class="token string">'simulink/Math Operations/Add'</span><span class="token punctuation">,</span><span class="token string">'my_model/Add'</span><span class="token punctuation">)</span><span class="token punctuation">;</span></code></pre>
</td>
</tr>
<tr>
<th>Layout and connect</th>
<td valign="top">
<pre class="language-matlab"><code class="language-matlab"><span class="token function">simlayout</span><span class="token punctuation">(</span>sys<span class="token punctuation">.</span>handle<span class="token punctuation">)</span></code></pre>
</td>
<td>
<pre class="language-matlab"><code class="language-matlab"><span class="token function">set_param</span><span class="token punctuation">(</span><span class="token string">'my_model/From Workspace'</span><span class="token punctuation">,</span><span class="token string">'Position'</span><span class="token punctuation">,</span><span class="token string">'[30, 13, 95, 37]'</span><span class="token punctuation">)</span>
<span class="token function">set_param</span><span class="token punctuation">(</span><span class="token string">'my_model/Constant'</span><span class="token punctuation">,</span><span class="token string">'Position'</span><span class="token punctuation">,</span><span class="token string">'[45, 90, 75, 120]'</span><span class="token punctuation">)</span>
<span class="token function">set_param</span><span class="token punctuation">(</span><span class="token string">'my_model/Add'</span><span class="token punctuation">,</span><span class="token string">'Position'</span><span class="token punctuation">,</span><span class="token string">'[170, 47, 200, 78]'</span><span class="token punctuation">)</span>
<span class="token function">add_line</span><span class="token punctuation">(</span><span class="token string">'my_model'</span><span class="token punctuation">,</span><span class="token string">'From Workspace/1'</span><span class="token punctuation">,</span><span class="token string">'Add/1'</span><span class="token punctuation">,</span><span class="token string">'autorouting'</span><span class="token punctuation">,</span><span class="token string">'on'</span><span class="token punctuation">)</span><span class="token punctuation">;</span>
<span class="token function">add_line</span><span class="token punctuation">(</span><span class="token string">'my_model'</span><span class="token punctuation">,</span><span class="token string">'Constant/1'</span><span class="token punctuation">,</span><span class="token string">'Add/2'</span><span class="token punctuation">,</span><span class="token string">'autorouting'</span><span class="token punctuation">,</span><span class="token string">'on'</span><span class="token punctuation">)</span><span class="token punctuation">;</span></code></pre>
</td>
</tr>
</table>

## Quick start

Jump right in with the [installation guide](quickstart.md#install) and the [examples](quickstart.md#examples)!

© Copyright 2017 - 2018 by Marco Gavelli
