"use client";

import { motion } from "framer-motion";
import { useInView } from "framer-motion";
import { useRef } from "react";

export default function Experience() {
  const ref = useRef(null);
  const isInView = useInView(ref, { once: true, margin: "-100px" });

  return (
    <section ref={ref} className="py-24 bg-gradient-to-b from-background to-light">
      <div className="max-w-7xl mx-auto px-6 md:px-12 lg:px-20">
        <div className="flex flex-col items-center text-center">
          {/* Section Header */}
          <motion.div
            initial={{ opacity: 0, y: 30 }}
            animate={isInView ? { opacity: 1, y: 0 } : { opacity: 0, y: 30 }}
            transition={{ duration: 0.8, ease: [0.4, 0, 0.2, 1] }}
            className="mb-16"
          >
            <h2 className="text-4xl md:text-5xl font-extrabold text-dark mb-4">
              Looks native. Feels built-in.
            </h2>
            <p className="text-lg text-dark/70 max-w-2xl">
              Designed to blend seamlessly with iOS, Deets feels like it&apos;s always been part of your phone.
            </p>
          </motion.div>

          {/* iPhone Mockup */}
          <motion.div
            initial={{ opacity: 0, scale: 0.9, y: 50 }}
            animate={isInView ? { opacity: 1, scale: 1, y: 0 } : { opacity: 0, scale: 0.9, y: 50 }}
            transition={{ duration: 1, ease: [0.4, 0, 0.2, 1], delay: 0.2 }}
            className="relative w-full max-w-sm"
          >
            {/* iPhone Frame */}
            <div className="relative bg-dark rounded-[3rem] p-3 shadow-[0_20px_60px_rgb(0,0,0,0.3)]">
              {/* Notch */}
              <div className="absolute top-0 left-1/2 -translate-x-1/2 w-1/3 h-7 bg-dark rounded-b-3xl z-10"></div>

              {/* Screen */}
              <div className="relative bg-light rounded-[2.5rem] overflow-hidden aspect-[9/19.5]">
                {/* Status Bar */}
                <div className="absolute top-0 left-0 right-0 h-12 flex items-center justify-between px-8 text-dark text-xs font-semibold z-20">
                  <span>9:41</span>
                  <div className="flex items-center gap-1">
                    <svg className="w-4 h-4" fill="currentColor" viewBox="0 0 24 24">
                      <path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm-2 15l-5-5 1.41-1.41L10 14.17l7.59-7.59L19 8l-9 9z" />
                    </svg>
                  </div>
                </div>

                {/* App Content */}
                <div className="pt-12 px-6 pb-6 h-full">
                  <motion.div
                    initial={{ opacity: 0 }}
                    animate={isInView ? { opacity: 1 } : { opacity: 0 }}
                    transition={{ duration: 0.8, delay: 0.6 }}
                    className="space-y-4"
                  >
                    {/* App Header */}
                    <div className="flex items-center justify-between mb-6">
                      <h3 className="text-2xl font-bold text-dark">Deets</h3>
                      <button className="p-2 rounded-full bg-primary text-white">
                        <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 4v16m8-8H4" />
                        </svg>
                      </button>
                    </div>

                    {/* Contact Cards */}
                    <motion.div
                      initial={{ opacity: 0, y: 20 }}
                      animate={isInView ? { opacity: 1, y: 0 } : { opacity: 0, y: 20 }}
                      transition={{ duration: 0.6, delay: 0.8 }}
                      className="space-y-3"
                    >
                      {[1, 2, 3].map((i) => (
                        <div
                          key={i}
                          className="bg-white rounded-2xl p-4 shadow-[0_2px_10px_rgb(0,0,0,0.05)] border border-dark/5"
                        >
                          <div className="flex items-center gap-3">
                            <div className="w-12 h-12 rounded-full bg-gradient-to-br from-primary to-accent flex items-center justify-center text-white font-bold">
                              {i === 1 ? "JS" : i === 2 ? "AM" : "KL"}
                            </div>
                            <div className="flex-1 min-w-0">
                              <div className="h-3 bg-dark/20 rounded w-2/3 mb-2"></div>
                              <div className="h-2 bg-dark/10 rounded w-1/2"></div>
                            </div>
                          </div>
                        </div>
                      ))}
                    </motion.div>

                    {/* Scan Button */}
                    <motion.div
                      initial={{ opacity: 0, scale: 0.8 }}
                      animate={isInView ? { opacity: 1, scale: 1 } : { opacity: 0, scale: 0.8 }}
                      transition={{ duration: 0.6, delay: 1.2 }}
                      className="pt-4"
                    >
                      <button className="w-full bg-primary text-white font-semibold py-4 rounded-2xl shadow-lg hover:shadow-xl transition-all">
                        Scan New Card
                      </button>
                    </motion.div>
                  </motion.div>
                </div>

                {/* Home Indicator */}
                <div className="absolute bottom-2 left-1/2 -translate-x-1/2 w-1/3 h-1 bg-dark/30 rounded-full"></div>
              </div>
            </div>

            {/* Glow Effect */}
            <div className="absolute inset-0 -z-10 blur-3xl opacity-30">
              <div className="absolute inset-0 bg-gradient-to-br from-primary via-accent to-primary"></div>
            </div>
          </motion.div>

          {/* Bottom Text */}
          <motion.p
            initial={{ opacity: 0, y: 20 }}
            animate={isInView ? { opacity: 1, y: 0 } : { opacity: 0, y: 20 }}
            transition={{ duration: 0.8, delay: 1.4, ease: [0.4, 0, 0.2, 1] }}
            className="mt-12 text-dark/60 text-sm max-w-md"
          >
            Built with Apple&apos;s design principles. Optimized for speed. Perfect for professionals.
          </motion.p>
        </div>
      </div>
    </section>
  );
}
