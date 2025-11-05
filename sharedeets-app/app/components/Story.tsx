"use client";

import { motion } from "framer-motion";
import { useInView } from "framer-motion";
import { useRef } from "react";

export default function Story() {
  const ref = useRef(null);
  const isInView = useInView(ref, { once: true, margin: "-100px" });

  return (
    <section ref={ref} className="py-24 bg-background">
      <div className="max-w-7xl mx-auto px-6 md:px-12 lg:px-20">
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-12 lg:gap-16 items-center">
          {/* Visual Side */}
          <motion.div
            initial={{ opacity: 0, x: -50 }}
            animate={isInView ? { opacity: 1, x: 0 } : { opacity: 0, x: -50 }}
            transition={{ duration: 0.8, ease: [0.4, 0, 0.2, 1] }}
            className="relative"
          >
            <div className="relative rounded-3xl overflow-hidden shadow-[0_20px_60px_rgb(0,0,0,0.15)]">
              {/* Placeholder for networking photo */}
              <div className="aspect-[4/3] bg-gradient-to-br from-primary/20 via-accent/10 to-primary/20 flex items-center justify-center">
                {/* Illustrated networking scene */}
                <div className="relative w-full h-full flex items-center justify-center p-12">
                  {/* Two people connecting */}
                  <div className="flex items-center justify-center gap-8">
                    {/* Person 1 */}
                    <motion.div
                      initial={{ opacity: 0, scale: 0.8, x: -20 }}
                      animate={isInView ? { opacity: 1, scale: 1, x: 0 } : { opacity: 0, scale: 0.8, x: -20 }}
                      transition={{ duration: 0.6, delay: 0.3 }}
                      className="flex flex-col items-center"
                    >
                      <div className="w-24 h-24 rounded-full bg-gradient-to-br from-primary to-primary/70 shadow-xl mb-4 flex items-center justify-center">
                        <svg className="w-12 h-12 text-white" fill="currentColor" viewBox="0 0 24 24">
                          <path d="M12 12c2.21 0 4-1.79 4-4s-1.79-4-4-4-4 1.79-4 4 1.79 4 4 4zm0 2c-2.67 0-8 1.34-8 4v2h16v-2c0-2.66-5.33-4-8-4z" />
                        </svg>
                      </div>
                      <div className="bg-white rounded-2xl px-6 py-3 shadow-lg">
                        <div className="h-2 w-16 bg-dark/20 rounded"></div>
                      </div>
                    </motion.div>

                    {/* Connection indicator */}
                    <motion.div
                      initial={{ scale: 0, opacity: 0 }}
                      animate={isInView ? { scale: 1, opacity: 1 } : { scale: 0, opacity: 0 }}
                      transition={{ duration: 0.6, delay: 0.6 }}
                      className="flex flex-col items-center"
                    >
                      <motion.div
                        animate={{
                          scale: [1, 1.2, 1],
                          rotate: [0, 180, 360],
                        }}
                        transition={{
                          duration: 2,
                          repeat: Infinity,
                          ease: "easeInOut",
                        }}
                      >
                        <svg className="w-8 h-8 text-primary" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                          <path
                            strokeLinecap="round"
                            strokeLinejoin="round"
                            strokeWidth={2}
                            d="M8 7h12m0 0l-4-4m4 4l-4 4m0 6H4m0 0l4 4m-4-4l4-4"
                          />
                        </svg>
                      </motion.div>
                    </motion.div>

                    {/* Person 2 */}
                    <motion.div
                      initial={{ opacity: 0, scale: 0.8, x: 20 }}
                      animate={isInView ? { opacity: 1, scale: 1, x: 0 } : { opacity: 0, scale: 0.8, x: 20 }}
                      transition={{ duration: 0.6, delay: 0.3 }}
                      className="flex flex-col items-center"
                    >
                      <div className="w-24 h-24 rounded-full bg-gradient-to-br from-accent to-accent/70 shadow-xl mb-4 flex items-center justify-center">
                        <svg className="w-12 h-12 text-white" fill="currentColor" viewBox="0 0 24 24">
                          <path d="M12 12c2.21 0 4-1.79 4-4s-1.79-4-4-4-4 1.79-4 4 1.79 4 4 4zm0 2c-2.67 0-8 1.34-8 4v2h16v-2c0-2.66-5.33-4-8-4z" />
                        </svg>
                      </div>
                      <div className="bg-white rounded-2xl px-6 py-3 shadow-lg">
                        <div className="h-2 w-16 bg-dark/20 rounded"></div>
                      </div>
                    </motion.div>
                  </div>
                </div>
              </div>

              {/* Decorative border */}
              <div className="absolute inset-0 rounded-3xl border-2 border-white/50"></div>
            </div>

            {/* Floating badge */}
            <motion.div
              initial={{ opacity: 0, y: 20 }}
              animate={isInView ? { opacity: 1, y: 0 } : { opacity: 0, y: 20 }}
              transition={{ duration: 0.8, delay: 0.8, ease: [0.4, 0, 0.2, 1] }}
              className="absolute -bottom-6 -right-6 bg-white rounded-2xl px-6 py-4 shadow-[0_8px_30px_rgb(0,0,0,0.15)] border border-dark/5"
            >
              <div className="flex items-center gap-3">
                <div className="text-3xl font-bold text-primary">∞</div>
                <div>
                  <div className="text-xs text-dark/60 font-semibold uppercase tracking-wide">Connections</div>
                  <div className="text-lg font-bold text-dark">Unlimited</div>
                </div>
              </div>
            </motion.div>
          </motion.div>

          {/* Text Side */}
          <motion.div
            initial={{ opacity: 0, x: 50 }}
            animate={isInView ? { opacity: 1, x: 0 } : { opacity: 0, x: 50 }}
            transition={{ duration: 0.8, ease: [0.4, 0, 0.2, 1], delay: 0.2 }}
            className="space-y-6"
          >
            <h2 className="text-4xl md:text-5xl font-extrabold text-dark leading-tight">
              Deets bridges moments
            </h2>

            <div className="space-y-4 text-lg text-dark/70 leading-relaxed">
              <p>
                You meet hundreds of people. Conferences. Coffee shops. Chance encounters that could change everything.
              </p>
              <p>
                But business cards get lost. Names fade. Details slip through the cracks.
              </p>
              <p className="text-dark font-semibold">
                Deets helps you keep them close.
              </p>
            </div>

            {/* Stats */}
            <motion.div
              initial={{ opacity: 0, y: 20 }}
              animate={isInView ? { opacity: 1, y: 0 } : { opacity: 0, y: 20 }}
              transition={{ duration: 0.8, delay: 0.6, ease: [0.4, 0, 0.2, 1] }}
              className="grid grid-cols-2 gap-6 pt-6"
            >
              <div className="bg-gradient-to-br from-primary/10 to-primary/5 rounded-2xl p-6 border border-primary/20">
                <div className="text-3xl font-bold text-primary mb-1">&lt;3s</div>
                <div className="text-sm text-dark/70 font-medium">Average scan time</div>
              </div>
              <div className="bg-gradient-to-br from-accent/10 to-accent/5 rounded-2xl p-6 border border-accent/20">
                <div className="text-3xl font-bold text-accent mb-1">99%</div>
                <div className="text-sm text-dark/70 font-medium">Accuracy rate</div>
              </div>
            </motion.div>
          </motion.div>
        </div>
      </div>
    </section>
  );
}
