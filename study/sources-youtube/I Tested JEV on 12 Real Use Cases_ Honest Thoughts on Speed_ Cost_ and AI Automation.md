---
título: "I Tested JEV on 12 Real Use Cases: Honest Thoughts on Speed, Cost, and AI Automation"
fonte: "https://www.youtube.com/watch?v=ymgH8jS6Wb8"
plataforma: "YouTube"
data: "22/09/2026"
duração: "00:16:08"
idioma: en
tags:
  - ai
  - jev
  - ai-automation
  - classification
  - model-routing
  - llm-costs
  - real-time-ai
  - workflow-automation
tópicos:
  - "Artificial Intelligence > Decision Models"
  - "Artificial Intelligence > Model Routing"
  - "Automation > Production Workflows"
  - "Automation > Data Classification"
  - "Business > Customer Support"
  - "Content Creation > Social Media Analysis"
  - "Finance > Algorithmic Trading"
---

---

## Resumo

### What JEV is and how it works

JEV is presented as a fundamentally different type of AI model. Unlike conversational models that generate text, reason through prompts, or summarize information, JEV is designed to make calibrated decisions. Its output consists of structured results such as yes-or-no decisions, category selections, confidence levels, and numerical scores. For example, it can determine whether a support ticket is urgent, route it to a technical or billing team, and assign a frustration score. The user defines the decision criteria, the available categories, and the meaning of each score, while JEV applies those rules consistently across large amounts of data.

The underlying approach is described as RLCD, or reinforcement learning for calibrated decisions. The model is intended for classification and decision-making workflows rather than open-ended conversation. Its three main decision types are binary decisions, called null decisions in the video, category or choice decisions, and scores assigned along a defined scale.

### Speed, cost, and limitations

The main reason JEV is attracting attention is its claimed efficiency. According to the announcement discussed in the video, it can be between 20 and 200 times faster and between 40 and 400 times cheaper than conventional models, partly because output tokens are free and the model does not need to generate long explanations. In the demonstrations, JEV processed large batches of data considerably faster and at a much lower cost than other models such as Luna, with the difference becoming especially significant when thousands of decisions are made every day.

The model is not a replacement for frontier AI systems. It cannot write, summarize, identify broad themes, brainstorm, hold a conversation, or perform deep analysis by itself. It also has a smaller context window of approximately 64,000 tokens, compared with models that can handle around one million tokens. Its strength is making clearly defined decisions at scale. The recommended architecture is therefore to use JEV as a first-pass filter or router and send only the relevant or more complex items to a stronger generative model.

### Email classification at scale

The first major demonstration involved classifying 1,000 emails using several questions at once. The configured decisions included whether an email was an invoice or receipt, whether it was a brand deal, whether it was a scam or phishing attempt, what type of email it was, how urgent it was, and how well it fit a sponsorship profile. This example illustrated all three of JEV's main capabilities: binary classification, categorical classification, and scoring.

In one run, JEV processed the thousand emails in approximately 70 seconds for around nine cents. After the backend was optimized to process larger payloads and more requests in parallel, the same type of workload was completed in roughly six seconds for the same cost. A single invoice-or-receipt classification took about four seconds and cost five cents, identifying 237 positive cases and 763 negative ones. By comparison, Luna took approximately five minutes and cost 62 cents for the broader classification task, making it around 12 times more expensive and 46 times slower in that test.

### YouTube comments, school posts, and production databases

The same approach was applied to YouTube comments. JEV could determine the comment type, whether it deserved a reply, whether it suggested a video idea, its sentiment, and the difficulty of the question. Processing 1,000 comments took about five seconds and cost approximately five cents. The creator also showed how similar rules could be applied to school or community posts, including identifying requests for help, questions requiring a team response, churn risk, member experience level, and testimonial strength.

The important idea is to move these classifications from a manual dashboard into real automations. Every time a new comment, post, CRM entry, or website lead arrives, JEV could classify it and update a database automatically. The speed is useful, but the largest economic advantage appears when the workflow processes thousands or millions of items. In the demonstrated console, nearly 20,000 requests had cost only about 85 cents, highlighting how model economics can change when a low-cost decision model handles the high-volume layer of an automation.

### Real-time Chrome extension for X posts

One of the most compelling speed-based use cases was a Chrome extension that evaluated posts while the creator browsed X. The extension classified posts as breaking news, golden nuggets, or AI slop, while also identifying whether they were on topic or had potential as video ideas. JEV ran on the backend and reacted almost instantly as posts appeared on the screen, labeling them in real time.

This example demonstrates a case where latency matters directly to the user experience. A batch classification that takes a few seconds may be acceptable for a database, but a browsing assistant needs to respond immediately. The extension could help the user focus attention on valuable content and ignore posts that were likely low quality or generated as AI slop.

### Meeting analysis through structured questions

The video proposes using JEV to analyze meeting transcripts as they become available from tools such as Fireflies or Granola. Rather than asking JEV to summarize a transcript or discover themes independently, the user can define targeted questions: what type of call took place, whether decisions were made, whether action items were defined, who owns the next steps, whether there is revenue relevance, and whether anything is waiting on a specific person.

This turns structured classification into a form of operational analysis. JEV does not directly tell the user what the organization should improve, but a carefully designed collection of questions can produce data that reveals patterns. For example, if many meetings lack clearly defined next steps, owners, or deadlines, that result can be used to improve the way meetings are conducted. The model supplies structured signals, and the human interprets those signals to identify broader themes.

### Video clip evaluation and content repurposing

Another experiment involved breaking YouTube videos into clips with a more capable model and then asking JEV to evaluate each clip. It assessed whether a clip could stand on its own, the strength of its hook, the type of clip, whether it required on-screen visuals, and whether it contained a quotable line. This type of workflow allows a large library of video segments to be screened cheaply before a human or a more expensive model invests time in selecting and repurposing content.

The broader principle is to use JEV to make many narrow judgments over a large corpus of information. Those judgments can identify material worth reposting, reveal patterns in the creator's communication style, and support decisions about which content deserves deeper analysis.

### Customer support, contracts, leads, and brain-dump routing

The video identifies customer support as one of the strongest practical applications. Incoming messages can be routed according to sentiment, urgency, issue type, required action, and team ownership. Because support operations involve a large number of repetitive decisions, JEV can reduce costs and accelerate routing before a human or a generative model handles the actual response.

Other suggested applications include reviewing incoming contracts for risk type and clause type, evaluating jobs and leads for red flags and quality, and routing personal brain dumps. In the latter case, JEV could classify notes as ideas, tasks, journals, deadlines, or high-priority items, while also assigning them to an area of life. These workflows do not require JEV to write a response; they require it to impose structure on unstructured information.

### Real-time crypto trading proof of concept

The creator also built a paper-trading proof of concept in which JEV evaluated Bitcoin every second and predicted whether the price would go up, go down, or remain unclear. The confidence levels changed continuously, and those decisions were used to determine whether the system should buy or sell. This experiment was explicitly described as insufficiently vetted and not ready to be trusted with real money.

The attraction of this use case is JEV's low latency and low operating cost. Running the decision process continuously with JEV was estimated at roughly two dollars per day, while using more capable models would have been substantially more expensive. However, trading fees and the reliability of the predictions were larger concerns than the model cost itself. The example is best understood as a demonstration of what fast decision-making makes possible, not as financial advice or a validated trading strategy.

### Model routing, browser use, and evaluation

JEV should be treated as one component in a larger model-routing system. It can rapidly classify or prioritize items, after which a different model can perform writing, reasoning, browser control, or another action that JEV cannot perform. In browser automation, for instance, JEV may decide what should happen, but another model may be required to type, navigate, or execute the action in the browser.

The video strongly recommends running evaluations before trusting JEV in production. A team should create a golden dataset containing representative inputs and correct answers, run the same tests through JEV and alternative models, and compare accuracy, cost, and speed. A low price is only valuable if the model's decisions are accurate enough for the intended workflow. The correct choice depends on the consequences of errors, the required latency, and the volume of requests.

### When to use JEV instead of a generative model

JEV is best suited to workflows involving thousands of items, large data corpora, repetitive classification, structured decisions, and real-time production routing. It is particularly valuable when each item can be evaluated through explicit questions, categories, yes-or-no criteria, or scoring scales. Examples include email triage, customer support routing, lead qualification, content moderation, meeting metadata, social-media filtering, and database enrichment.

A conventional model such as ChatGPT remains preferable when there are only a few items, when the user needs explanations, brainstorming, conversation, summaries, deep analysis, or original text generation. The strongest architecture combines both approaches: JEV handles the inexpensive, high-throughput decisions, while a more capable model receives the smaller set of items that require reasoning or language generation.

---

## Takeaways

- JEV is a decision and classification model, not a conversational or text-generation model.
- Its main advantages are extremely low cost, high throughput, and very low latency for structured decisions.
- The user must define precise questions, categories, scoring criteria, and confidence requirements for JEV to produce useful results.
- A powerful pattern is to use JEV as a cheap first-pass filter and route only selected items to a more capable generative model.
- Email, customer support, social-media posts, YouTube comments, leads, contracts, meeting transcripts, and personal notes are strong candidates for JEV-based automation.
- The economic advantage becomes most significant when a workflow processes thousands of requests repeatedly in production.
- JEV does not independently discover themes or provide deep analysis; structured questions must be designed so the resulting data can reveal patterns.
- Backend parallelization and larger payloads can make JEV workflows dramatically faster.
- JEV should not be trusted automatically: benchmark it against a golden dataset and compare accuracy, speed, and cost with other models.
- For browser automation and other actions, JEV may make the decision while another model or tool executes the action.
- The crypto-trading example demonstrates technical potential, not a validated or safe investment strategy.
- Use a generative model when the task requires writing, explanation, conversation, brainstorming, summarization, or deep reasoning.

---

## Transcrição

### Introdução e exemplos de uso

So JEV is literally everywhere, and I think it's going to change how AI automations are built. So I came in here and tested it on 12 use cases and compared it with other AI models on things like speed and cost. I was even able to build this Chrome extension that will label tweets as breaking, golden nuggets, or AI slop in real time for me. On the back end, you can see that it uses JEV to actually instantly categorize all the stuff as soon as it enters my screen. It's not doing very well in the first hour, but I also made this JEV Trader, which is literally every single second analyzing if Bitcoin's gonna go up or go down or stay, and then it basically places trades in real time for me because this model is so good at quick decisions.

But, anyways, by the end of this video, you'll understand how JEV works and where you should actually use it in your life. So let's not waste any time and just get straight into this.

### O que é JEV

Alright. We're gonna start off with just, what is JEV? I'm not gonna do a super, super deep dive, just enough for you to understand how it works and what we're looking at in today's video.

So the interesting thing about JEV is that it's an AI that makes decisions, but it doesn't write anything. It doesn't output tokens. It's not anything that you could actually have a conversation with. It just makes decisions.

So here was kind of the announcement tweet from Diogo. He co-invented ChatGPT, and then he has been building in the past two years this new way to train models, RLCD. And you can see what that stands for is reinforcement learning for calibrated decisions. And this is on TypeSafe's blog.

And by the way, if you want to actually get in here so that you can start playing around with JEV, then go to TypeSafe AI and join the waitlist. And then, hopefully, in a few hours, you're able to sign in. But, also, this is available through Vercel's gateway as well as OpenRouter. So if you're not in the waitlist yet, then you can still go out and play with JEV.

### Como o modelo toma decisões

Essentially, what happens is instead of a normal chat model where you would send in a message like this, this is some sort of support ticket, and the AI model would read it, would reason, would think, and then output a message or output some sort of classification. It basically just outputs these types of things, which are a yes or no confidence level, a category, and sort of a score.

So for the first one, is it urgent? Ninety-nine percent confidence is yes. It is urgent. Which team? There were probably multiple routes like technical or billing or support, and it labeled it as technical. And then how frustrated, it gave it a one out of two on the frustration score or scale.

But you're fully in control. You basically will set up JEV with, hey, this is essentially how you're supposed to make decisions, and here is sort of the classification criteria.

So it's three types of decisions, like I said. The yes or no is called a null. The pick one is a choice, and then we have an actual score. And I'm gonna show you real examples of all of these being run on these 12 use cases, so don't worry. But I just wanted to sort of lay the foundation here.

So, like I said, in this example, it's yes or no, and there's a confidence score. And in the team or categorization example, it's different categories as well as a confidence score and then a score from zero to 10 on some sort of scale. And in here, one meant that they were frustrated.

### Velocidade, custo e limitações

The reason why this is getting so much traction is because Diogo said that this is 20 to 200 times faster and 40 to 400 times cheaper, with output tokens being free.

And so if we look at the speed here compared to models like Terra and Luna and Sol, this thing is gonna be a lot faster. This was just one very quick test I ran. This doesn't mean that Terra is always faster than Luna, but this was just one quick example of how significantly faster JEV is. Once again, it doesn't have to output all these tokens or reason. It just, boom, makes a decision and outputs it in this JSON format.

And same thing from a cost perspective. If you were running thousands and thousands of decisions per day, this is what it could actually end up looking like. Now, obviously, the important thing is you're paying a lot less, so you wanna make sure that the quality is the exact same as what you'd be getting here or here to justify it. We're just looking at the cost right now; it is significantly cheaper, and it is proven that it's significantly cheaper.

So what it cannot do is write or summarize or find themes or do deep analysis. It basically just outputs decisions. And one other limitation right now is that it has a very small input context window. It's 64,000 tokens, whereas a lot of the models that we're used to using today, whether that be Claude or GPT, are more on the side of a million tokens.

### Quando usar JEV

So if we look at this on a use case like YouTube comments, if I fed in 5,000 YouTube comments, JEV could sort them for way cheaper and way faster than any AI model could, and then it could categorize them as, hey, these need a reply; these are stuck; these people wanna buy.

And then what you could do is feed it a more intelligent AI model, an AI model that actually responds to things and outputs things, and you could say, hey, ChatGPT, could you read just these now and then help me analyze themes or help me respond to these ones or something like that? And that way, you're not using a slower and more expensive model to actually categorize all of those comments in the first place.

Because JEV isn't a frontier AI model. It's not even in the same bucket as Astra or Fable. It's a completely different type of model.

So when to use it? If you have thousands of things, if you have a corpus of data, if you need to classify things, make decisions, or you're running some sort of decision-based or classification-based workflow at scale and in production. If you need very quick, real-time decisions, because it's really, really fast.

And stay with ChatGPT if you need things like a handful of items, you need to understand why, you need to brainstorm, you need to chat, things like that.

### Demonstração com e-mails

Anyways, let's just get straight into some use cases here. So I know this might look a little bit intimidating of a screen, but what I wanna show you is a little bit of a playground of how this actually works.

By the way, guys, I've got this completely free SOP for you about getting your first AI automation client. It's gonna go over the exact steps that have been proven for hundreds of our AI Plus members to get their first paid gigs. It goes over the one-sentence service pitch that can get you started today, why your first client should cost you money, the five-minute video that answers, can this person actually deliver before you've actually received any money, what to do when you have zero case studies. There's so many good things in here that are gonna help you out. Even if you already do have clients, I would recommend grabbing this because, like I said, it's yours completely free. So if you wanna grab this, there's a link for it down in the description. Let's get back to the video.

So the first one we're looking at is emails. Now, real quick, you can see that I've got a bunch of different categories set up or a bunch of different questions set up. The first one is invoice or receipt. This is a yes or no. The second one is brand deal. This is yes or no. Scammer phishing. Yes or no. We also have email type. We also have urgency, and we also have sponsor fit. So we've got different types of scoring and different types of categorization.

And you can see here, if I run this real quick, if I go to redo everything and I hit run, we're currently using the model JEV, and this is a thousand emails. Look how quick this is able to classify a thousand emails. So it did that in about 70 seconds for nine cents.

Now, obviously, that's not super, super fast, like lightning fast, but this was not parallelized. If we were to run all of those individually in parallel, it would have been so much faster. But I just wanted to show the difference here. Let's even go to something like GPT-5.6 Luna, and we'll run this again on everything. So, all a thousand. I mean, this feels like it took forever. With Luna, that took five minutes, and it was 62¢ compared to 70 seconds, and I think it was 9¢.

And, also, think about it. It wasn't just doing one sort of classification. It was doing all seven of these rules. And I actually just changed the back end to make this process things more in parallel with bigger payloads. So I'm just gonna run this now, and you'll see how much quicker this really is. Boom. Look how fast that went. That took six seconds, and it once again was 9¢. So that just shows how you can optimize that back end to make JEV go even faster. And you could do the same thing with Luna, but it's just not gonna be as fast as six seconds for a thousand emails across seven categories.

### Classificação, categorias e pontuações

So I know that this interface may be a little overwhelming. Let's just get rid of everything here except for invoice or receipt. So this is literally just us saying, okay, we wanna set up some sort of classification for all of these thousand emails. We're gonna give it a name. We're going to ask the question, is this email a receipt, invoice, payment confirmation, or billing notice? And then we just define what counts as yes. So it has a charge, a payment, a payout, or some sort of failed payout, and we call it a yes when JEV is at least 50% confident.

So that's kind of the thing that we're running here, and I would just go ahead and choose redo everything. And so when we run this, it's basically gonna look at all a thousand of those emails and just decide, is that an invoice or receipt? It comes back in four seconds for 5¢. And where it landed was no on 763 of them, but yes on 237 of them.

Here is a category example where we actually set up the email type, whether it's notification, newsletter, billing, opportunity. And you can see, if I edit this, what we did is we actually had to choose the options and define each of them. So this is a pretty standard AI classification type of automation.

But then if we look at the scoring—for example, if we look at the sponsor fit—if I go to what this one looks like, this is rating it on a scale, and we basically choose from lowest to highest what that looks like as far as not a sponsorship inquiry at all or if it's a strong fit, and it will choose the level. So you can see here, it shows that 942 of them were one, and then it—we didn't have any that were strong fits.

You can see there was another score when that was urgency, about if there was action needed or nothing needed at all. And this was a little bit more even across the board. The average was 2.8 out of five.

So, anyways, email classification is one example. And, obviously, when you're looking at the actual cost and speed here, that first example we ran, Luna was 12 times the cost and 46 times the time, and that was also just Luna. What if we went up to Terra and Sol? How much more expensive that would have been and how much more that would have cost us?

### Comentários, automações e economia de IA

So a lot of these use cases are kind of on the classification side. I did the exact same thing here with YouTube comments, where I can choose categories or yes and no and score, and I can analyze thousands of comments at a time on things like comment type, if they're worth a reply, if it gives me a video idea, what the sentiment is, and what the question difficulty is.

And once again, if I run JEV on all a thousand of these, look how quick that actually goes. It would be so much longer if we used any other sort of AI model: five seconds for 5¢.

And if we actually go to my JEV console real quick and I go ahead and refresh, this is going to show that I've used 85¢ with JEV. But look how many requests I've done. I've done almost 20,000 requests. Think about what 20,000 requests on a different AI model would have cost us.

And I can also do the exact same thing with my school posts. I can set up my custom categories or my custom classification criteria to see what type of questions we have, if they need help, if we need a team answer, if there's churn risk, member experience level, and testimonial strength.

And, yes, this is kind of like a dashboard playground view, but what if you had this in an actual automation every single time a new post got made, you updated the database? Every single time a new YouTube comment came in, you updated the database? Every time there's a new internal CRM entry or every time there's a new lead that submitted a form on your website? There's so many things you can do here.

And even though the speed might not matter a ton when it comes to actually having automations in production, what does add up really quickly is the cost. Because once again, when you start to run thousands and thousands of requests through, it's going to add up big time. So when you talk about AI economics and model routing, this is definitely gonna be a game changer.

### Extensão para X e análise de reuniões

Now here's another interesting one where the speed really did matter. I have this one called X Feed, where it basically pulls in a bunch of posts on my feed, and it will tell me, are they on topic or what's the category? Is it breaking news? Is there video idea potential? So, similar classification as we saw in these first three.

But look what else I did. If I give my X a hard refresh real quick, you'll see that in the bottom left, I have this thing called JEV judged, and you can see that it judged that one a slop. And as I scroll through, this is a Chrome extension that it built for me, where it's looking at the X post and really quickly reading them and classifying them as breaking, golden nuggets, or AI slop.

It's basically gonna help me keep more focused while I'm scrolling through X to see, highlighting what might be good to read and what are things that I should probably just ignore because of AI slop. And this is just a Chrome extension that I built where it has JEV on the back end powering all of this. So that is a pretty cool use case, and it shows how fast this thing actually happens in production. I mean, look how fast it's reacting to these posts as they come onto my screen. It's basically instant.

I also thought about what you could do with your meetings here. You could analyze meetings as they get transcribed in Fireflies or Granola or whatever you use. And as soon as they come in, you can categorize them by what type of call it was, if you had decisions made, if you had action steps.

I thought this one was an interesting one. Because let's say you see that in a lot of your calls, you have no next steps discussed or defined clearly with ownership and timelines, then you can use the data to change how you're conducting your calls.

What I think is interesting is, JEV on its own doesn't analyze things for you. But if you're strategic with the way that you set up the questions, you can get analysis from it. You can have this data tell a story. You can't have JEV look at thousands of transcripts and say, hey, tell me what I need to do better about these meetings or tell me common themes. But what you can do is you can give it categories and you can give it scores. And then from all of these different types of questions that you set up, you tell your own story with that data.

You can see that there's not much tension in some of our calls. I mean, this one has someone says they're frustrated or overloaded, but all of these questions that I created for JEV here, there's some sort of takeaway from each of these. Are things waiting on Nate? Is there revenue relevance? Things like that.

### Clipes de vídeo e avaliação de modelos

And I also tried this use case with video clips, where I basically had Astra break up a bunch of my YouTube videos into clips. And then I had JEV look at those clips and tell me, is this possible to be posted on its own as a clip? A lot of them, no. What is the hook strength of these clips? What type of clips are these? Do I need the screen on them? Is there a quotable line inside of this clip?

And then I could start to have it pull out things that might be worth reposting somewhere else or might be worth me thinking about the way that I actually speak in these videos and things like that.

And so these were a lot of ways that I would think about how do I take a corpus of information, a ton and ton of data that I wanna have AI analyze, but instead of paying more for it and waiting longer, let's figure out how we can use the right questions to have JEV do it for us.

And then not only can we maybe have some sort of dashboard view, but how do we build JEV into our actual back-end automations, where it's really gonna benefit us to have a really cheap and fast model as we increase the throughput.

Now, I will say, don't just plug in JEV and trust what it says automatically. What you're really gonna wanna do is run evals. Meaning, you're going to have a golden dataset of 100 use cases and 100 correct answers, and then you're going to run JEV through those, and you're gonna run Opus through those, and you're gonna run Sol through those, and you're gonna see which model gives you the best balance of accuracy and cost. And if you care about speed in that use case, then also speed as well.

### Outros casos de uso

But here's some other things you could do. You could have it vet contracts for you as they come in. You could see the type of risk. You could see the type of clause. You could create any sort of questions that actually matter to you when you're vetting contracts.

Same thing with jobs and leads. You can get red flags. You can get lead quality. You can get next steps.

You can also do something like a brain dump router, where you're constantly just talking into your phone or you're talking into something, and then you're feeding that into JEV, and it can tell you what type of things you're talking about. If they're ideas or tasks or journals, if you have things that have deadlines, if you have things that are high priority, and what area of your life they're in.

There's so many ways to use this because a big part of what we do with AI, like I said, is just figuring out what to do with all of our data, and JEV can do that really well.

And then I think one of the best examples here is customer support. Just routing emails around, figuring out sentiment, urgency, what we need to do, how we categorize these sorts of things. I think that this is going to be a huge game changer for customer support because there's so many different decisions that have to be made, and JEV is really good and really fast and really cheap at making decisions.

### JEV Trader e negociações em tempo real

So here's another use case that I thought would be cool to just sort of POC. So this is paper trading. This isn't very vetted. There's a lot that's wrong with this. But I think that JEV being so real time and making decisions so fast, it's going to be really interesting to see how it affects things like day trading or trading crypto in real time.

So you can see every single second, JEV is basically predicting, is this gonna go up? Am I unclear? Is it gonna go down? You can see these confidence scores jumping around every single second, and that's how it decides what to do. That's how it decides down here to place trades, to buy things, or to sell things.

Now, unfortunately, there's a lot of these fees here. So the fees are way more expensive than JEV actually making decisions for us. So that's one issue where it's like, okay, well, how much would we actually have to be able to profit to make this worth it?

But right here, you can see just the cost of running these decisions. Look how much more this would have cost us per day with other models. Whereas JEV would just be costing us about $2 a day to run this 24/7, and Sol and Opus and Fable would be significantly more than JEV.

### Handoff entre modelos e conclusão

Now I've also seen people on X doing things like having JEV play video games and having JEV do different creative, fun things, and I think it's really cool, like the browser use and all that. It's cool to see what's possible, but I think you have to think about where's the handoff.

Because with browser use, it was unable to actually type things in. It would basically make decisions, then it would have to route to a different model that's better with actually controlling the browser to do things.

And that's why I wanted to show what this looks like for these examples, because I think building dashboards or automations where you have JEV powering it on the back end for things that you actually care about in your life, like these sorts of things, is where you'll start to play with JEV and actually get some return, and then later figure out how you can expand or extend your workflows with other models on the back end.

But, anyways, I hope seeing these examples, even though all of these were very similar in the realm of classification, I hope that it helps you understand how you can start to ask the right questions in here and how you can start to work it into things that you're doing to actually make sense out of it.

But that is gonna do it for this one. So if you guys enjoyed it or you learned something new, please give it a like. It helps me out a ton. And as always, I appreciate you guys made it to the end of the video, and I'll see you on the next one. Thanks, everyone.

---

*Transcrito automaticamente via OmniRoute · Enriquecido via cx/gpt-5.6-luna em 22/09/2026*